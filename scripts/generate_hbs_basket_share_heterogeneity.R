#!/usr/bin/env Rscript

# Figure 2: national weighted P20, P50, and P80 of household budget shares,
# aggregated to the euro area with 2022 HICP country weights.

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_file <- if (length(script_arg)) {
  sub("^--file=", "", script_arg[[1L]])
} else {
  "scripts/generate_hbs_basket_share_heterogeneity.R"
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

calibration_year <- 2022L
percentiles <- c(0.20, 0.50, 0.80)
countries <- c(
  "AT", "BE", "CY", "DE", "EE", "EL", "ES", "FI", "FR",
  "HR", "IE", "IT", "LT", "LU", "LV", "MT", "NL", "SI", "SK"
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

weighted_empirical_quantile <- function(x, weight, probability) {
  keep <- is.finite(x) & is.finite(weight) & weight > 0
  x <- x[keep]
  weight <- weight[keep]
  order_x <- order(x)
  x <- x[order_x]
  cumulative_weight <- cumsum(weight[order_x]) / sum(weight)
  x[which(cumulative_weight >= probability)[1L]]
}

country_budget_share_percentiles <- function(country_code) {
  message("Building household basket-share percentiles: ", country_code)
  prepared <- individual_prepare_country(build_root, country_code)
  households <- prepared$households
  inputs <- prepared$inputs

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
    year == calibration_year & is.finite(weight) & weight > 0
  ]
  use <- intersect(
    official_weights$coicop,
    prices[year == calibration_year, unique(coicop)]
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

  product_groups <- product_group_from_code(colnames(ras_weights))
  group_shares <- t(rowsum(t(ras_weights), group = product_groups, reorder = FALSE))
  group_shares <- 100 * group_shares
  share_sum_error <- max(abs(rowSums(group_shares) - 100))
  if (share_sum_error >= 1e-6) {
    stop("Broad-category shares do not sum to 100 for ", country_code,
         "; maximum error = ", signif(share_sum_error, 8))
  }

  result <- rbindlist(lapply(colnames(group_shares), function(group_name) {
    data.table(
      country = country_code,
      product_group = group_name,
      percentile = c("P20", "P50", "P80"),
      share = vapply(percentiles, function(probability) {
        weighted_empirical_quantile(
          group_shares[, group_name], survey_weight, probability
        )
      }, numeric(1L))
    )
  }))
  stopifnot(nrow(result) == 15L, all(is.finite(result$share)))
  result
}

country_percentiles <- rbindlist(lapply(countries, country_budget_share_percentiles))
country_weights <- individual_country_weights(
  build_root, countries = countries, years = calibration_year
)[, .(country, country_weight = normalized_country_weight)]
stopifnot(
  nrow(country_weights) == length(countries),
  abs(sum(country_weights$country_weight) - 1) < 1e-12
)
country_percentiles <- country_weights[country_percentiles, on = "country"]
ea_percentiles <- country_percentiles[, .(
  share = sum(share * country_weight),
  countries = uniqueN(country)
), by = .(product_group, percentile)]
stopifnot(all(ea_percentiles$countries == length(countries)))

plot_data <- dcast(
  ea_percentiles, product_group + countries ~ percentile, value.var = "share"
)
product_levels <- c(
  "Services",
  "Non-energy industrial goods",
  "Motor fuels and vehicle operation",
  "Food products",
  "Housing energy"
)
plot_data[, product_group := factor(product_group, levels = product_levels)]
setorder(plot_data, product_group)

plot <- ggplot(plot_data, aes(y = product_group)) +
  geom_segment(
    aes(x = P20, xend = P80, yend = product_group),
    linewidth = 2.2, colour = "#8CB6D9", lineend = "round"
  ) +
  geom_point(aes(x = P50), size = 3.4, colour = "#245B84") +
  scale_x_continuous(
    breaks = seq(0, 60, 10),
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.04))
  ) +
  labs(x = NULL, y = NULL) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.text.y = element_text(colour = "grey20"),
    axis.text.x = element_text(colour = "grey30"),
    plot.margin = margin(8, 18, 8, 8)
  )

figure_base <- file.path(
  paper_root, "fig", "fig_EA19_2022_hbs_basket_share_heterogeneity"
)
ggsave(paste0(figure_base, ".pdf"), plot, width = 8.2, height = 4.8, bg = "white")
ggsave(
  paste0(figure_base, ".png"), plot,
  width = 8.2, height = 4.8, dpi = 300, bg = "white"
)
fwrite(plot_data, paste0(figure_base, "_data.csv"))
fwrite(country_percentiles, paste0(figure_base, "_country_data.csv"))
message("Exported: ", figure_base, ".pdf")
