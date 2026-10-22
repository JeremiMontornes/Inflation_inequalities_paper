#!/usr/bin/env Rscript

# Appendix A.2: average RAS-calibrated non-rent consumption baskets by
# national total-income quintile in the common 18-country demographic sample.

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_file <- if (length(script_arg)) {
  sub("^--file=", "", script_arg[[1L]])
} else {
  "scripts/generate_appendix_income_baskets.R"
}
paper_root <- normalizePath(file.path(dirname(script_file), ".."), mustWork = TRUE)
build_root <- Sys.getenv(
  "INFLATIONINEQUALITY_BUILD_REPO",
  file.path(dirname(paper_root), "build-figures-tables")
)
package_root <- Sys.getenv(
  "INFLATIONINEQUALITY_PACKAGE_REPO",
  file.path(dirname(build_root), "inflationinequality")
)

if (requireNamespace("pkgload", quietly = TRUE) &&
    file.exists(file.path(package_root, "DESCRIPTION"))) {
  pkgload::load_all(package_root, quiet = TRUE)
} else {
  library(inflationinequality)
}
source(file.path(build_root, "scripts", "89_delta_cache_helpers.R"))
enable_delta_cache(build_root)
source(file.path(build_root, "scripts", "87_hbs_micro_objects.R"))
enable_HBS_micro(build_root)
source(file.path(build_root, "scripts", "90_ras_default_helpers.R"))
use_ras_weighting_by_default()
source(file.path(build_root, "scripts", "91_custom_ea20_income_helpers.R"))
source(file.path(build_root, "scripts", "94_hbs_micro_weights.R"))
source(file.path(build_root, "scripts", "95_hbs_hicp_crosswalk.R"))
source(file.path(build_root, "scripts", "98_individual_p20_p80_helpers.R"))

basket_year <- 2022L
countries <- c(
  "AT", "BE", "CY", "DE", "EE", "EL", "ES", "FI", "FR",
  "HR", "IE", "LT", "LU", "LV", "MT", "NL", "SI", "SK"
)
income_levels <- c(
  "First quintile", "Second quintile", "Third quintile",
  "Fourth quintile", "Fifth quintile"
)
income_labels <- c(
  "First quintile" = "Q1", "Second quintile" = "Q2",
  "Third quintile" = "Q3", "Fourth quintile" = "Q4",
  "Fifth quintile" = "Q5"
)

product_group_from_code <- function(coicop) {
  non_energy_goods <- c(
    "031", "032", "051", "052", "053", "054", "055", "061", "071",
    "082", "091", "092", "093", "095", "123"
  )
  fcase(
    substr(coicop, 1L, 2L) %chin% c("01", "02"), "Food products",
    startsWith(coicop, "045"), "Housing energy",
    startsWith(coicop, "072"), "Motor fuels and vehicle operation",
    coicop %chin% non_energy_goods, "Non-energy industrial goods",
    default = "Services"
  )
}

country_income_baskets <- function(country_code) {
  message("Building RAS income-quintile baskets: ", country_code)
  prepared <- individual_prepare_country(build_root, country_code)
  households <- prepared$households
  inputs <- prepared$inputs

  households[, household_size := suppressWarnings(as.numeric(HB05))]
  households[, residence := fcase(
    trimws(as.character(HA09)) == "1", "Cities",
    trimws(as.character(HA09)) %chin% c("2", "3"), "Rural",
    default = NA_character_
  )]
  eligible <- households[
    is.finite(household_size) & household_size > 0 &
      !is.na(age_group) & !is.na(income_group) & !is.na(residence) &
      is.finite(weight) & weight > 0,
    which = TRUE
  ]
  households <- households[eligible]
  stopifnot(
    nrow(households) > 0L,
    setequal(unique(households$income_group), income_levels)
  )

  mapping <- copy(as.data.table(inputs$mapping_HBS_HICP))
  mapping <- mapping[
    !hbs_micro_excluded(hbs_coicop, c("041", "042")) &
      !hbs_micro_excluded(hicp_coicop, c("041", "042"))
  ]
  stopifnot(nrow(mapping) > 0L, !anyDuplicated(mapping$hbs_variable))

  expenditure_raw <- suppressWarnings(as.matrix(
    households[, lapply(.SD, as.numeric), .SDcols = mapping$hbs_variable]
  ))
  expenditure_raw[!is.finite(expenditure_raw) | expenditure_raw < 0] <- 0
  expenditure <- t(rowsum(
    t(expenditure_raw), group = mapping$hicp_coicop, reorder = TRUE
  ))

  survey_weight <- households$weight
  national_mean <- drop(crossprod(survey_weight, expenditure)) / sum(survey_weight)
  names(national_mean) <- colnames(expenditure)
  codes <- names(national_mean)[is.finite(national_mean) & national_mean > 0]
  codes <- codes[!hbs_micro_excluded(codes, c("041", "042"))]
  relative_expenditure <- sweep(
    expenditure[, codes, drop = FALSE], 2L, national_mean[codes], "/"
  )

  prices <- copy(as.data.table(inputs$cpi_dt))[coicop %chin% codes]
  prices[, date := as.Date(sprintf("%04d-%02d-01", year, month))]
  setorder(prices, coicop, date)
  prices[, dec_ratio := hicp::unchain(value, date), by = coicop]
  complete <- prices[is.finite(dec_ratio) & dec_ratio > 0,
    .(months = uniqueN(month)), by = .(coicop, year)][months == 12L]
  prices <- prices[complete, on = .(coicop, year), nomatch = 0]

  official_weights <- copy(as.data.table(inputs$index_weights_dt))[
    year == basket_year & is.finite(weight) & weight > 0
  ]
  use <- intersect(
    official_weights$coicop,
    prices[year == basket_year, unique(coicop)]
  )
  official_weights <- official_weights[match(use, coicop)]
  raw_weights <- sweep(
    relative_expenditure[, use, drop = FALSE],
    2L, official_weights$weight, "*"
  )

  retained_expenditure <- rowSums(expenditure[, codes, drop = FALSE])
  expenditure_mass <- survey_weight * retained_expenditure
  row_mass <- expenditure_mass / sum(expenditure_mass)
  calibrated <- micro_ras_calibrate(
    raw_weights, row_mass, official_weights$weight,
    tolerance = 1e-10, max_iter = 10000L
  )
  ras_weights <- calibrated$weights
  colnames(ras_weights) <- use
  stopifnot(max(abs(rowSums(ras_weights) - 1)) < 1e-7)

  baskets <- rbindlist(lapply(income_levels, function(income_group) {
    selected <- which(households$income_group == income_group)
    group_mass <- expenditure_mass[selected]
    basket <- colSums(ras_weights[selected, , drop = FALSE] * group_mass) /
      sum(group_mass)
    data.table(
      country = country_code,
      income_quintile = income_group,
      coicop = names(basket),
      share = 100 * as.numeric(basket)
    )
  }))
  baskets[, product_group := product_group_from_code(coicop)]
  baskets <- baskets[, .(share = sum(share)),
    by = .(country, income_quintile, product_group)]
  stopifnot(max(abs(baskets[, sum(share), by = income_quintile]$V1 - 100)) < 1e-7)

  diagnostics <- households[, .(
    households = .N,
    survey_share = 100 * sum(weight) / sum(households$weight),
    expenditure_share = 100 * sum(expenditure_mass[.I]) / sum(expenditure_mass)
  ), by = .(income_quintile = income_group)]
  diagnostics[, country := country_code]
  list(baskets = baskets, diagnostics = diagnostics)
}

country_results <- lapply(countries, country_income_baskets)
basket_country <- rbindlist(lapply(country_results, `[[`, "baskets"))
diagnostics <- rbindlist(lapply(country_results, `[[`, "diagnostics"))

country_weights <- individual_country_weights(
  build_root, countries = countries, years = basket_year
)[, .(country, country_weight = normalized_country_weight)]
stopifnot(
  nrow(country_weights) == length(countries),
  abs(sum(country_weights$country_weight) - 1) < 1e-12
)
basket_country <- country_weights[basket_country, on = "country"]
basket_ea <- basket_country[, .(
  share = sum(share * country_weight),
  countries = uniqueN(country)
), by = .(income_quintile, product_group)]
stopifnot(
  all(basket_ea$countries == length(countries)),
  max(abs(basket_ea[, sum(share), by = income_quintile]$V1 - 100)) < 1e-7
)

product_levels <- c(
  "Services",
  "Non-energy industrial goods",
  "Motor fuels and vehicle operation",
  "Housing energy",
  "Food products"
)
basket_ea[, product_group := factor(product_group, levels = product_levels)]
basket_ea[, income_quintile := factor(income_quintile, levels = income_levels)]
basket_ea[, income_label := factor(
  unname(income_labels[as.character(income_quintile)]),
  levels = unname(income_labels[income_levels])
)]
setorder(basket_ea, income_quintile, product_group)

palette <- c(
  "Food products" = "#E6AB02",
  "Housing energy" = "#D95F02",
  "Motor fuels and vehicle operation" = "#1F78B4",
  "Non-energy industrial goods" = "#7570B3",
  "Services" = "#1B9E77"
)
plot <- ggplot(basket_ea, aes(x = income_label, y = share, fill = product_group)) +
  geom_col(width = 0.64) +
  scale_fill_manual(values = palette, breaks = rev(product_levels), name = NULL) +
  scale_y_continuous(breaks = seq(0, 100, 25), expand = expansion(mult = c(0, 0))) +
  coord_cartesian(ylim = c(0, 100), expand = FALSE) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  ) +
  guides(fill = guide_legend(ncol = 2, byrow = TRUE))

figure_base <- file.path(
  paper_root, "fig", "fig_EA18_2022_income_consumption_baskets"
)
ggsave(paste0(figure_base, ".pdf"), plot, width = 7.2, height = 5, bg = "white")
ggsave(
  paste0(figure_base, ".png"), plot,
  width = 7.2, height = 5, dpi = 300, bg = "white"
)
fwrite(basket_ea, paste0(figure_base, "_data.csv"))
fwrite(basket_country, paste0(figure_base, "_country_data.csv"))
fwrite(diagnostics, paste0(figure_base, "_diagnostics.csv"))
message("Exported: ", figure_base, ".pdf")
