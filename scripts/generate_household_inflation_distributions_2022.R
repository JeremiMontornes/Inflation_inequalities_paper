#!/usr/bin/env Rscript

# Five-panel adaptation of O'Flaherty (2026b), Figure 6.
# The figure compares household-level inflation distributions across observable
# groups after removing each country's survey-weighted mean inflation rate.

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(grid)
  library(readxl)
})

script_file <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_file <- if (length(script_file)) {
  sub("^--file=", "", script_file[[1]])
} else {
  "scripts/generate_household_inflation_distributions_2022.R"
}
paper_repo <- normalizePath(file.path(dirname(script_file), ".."), mustWork = TRUE)
build_repo <- Sys.getenv(
  "INFLATIONINEQUALITY_BUILD_REPO",
  file.path(dirname(paper_repo), "build-figures-tables")
)

basket_year <- 2020L
inflation_year <- 2022L
inflation_cache <- file.path(
  build_repo, "outputs", "section4_ras", "v3_hbs_micro", "income",
  "observed_rates.rds"
)
if (!file.exists(inflation_cache)) stop("Missing household-inflation cache: ", inflation_cache)

read_household_covariates <- function(country) {
  path <- file.path(build_repo, "data", sprintf("HBS_HH_%s.xlsx", country))
  dt <- as.data.table(read_excel(path, na = c("NA", "", " ")))
  required <- c("HA04", "COUNTRY", "YEAR", "HA09", "HB05")
  if (length(setdiff(required, names(dt)))) stop("Missing household covariates for ", country)
  dt <- dt[COUNTRY == country & as.integer(YEAR) == basket_year]
  dt[, .(
    household_id = paste(country, basket_year, HA04, sep = "_"),
    density_code = trimws(as.character(HA09)),
    household_size = suppressWarnings(as.numeric(HB05))
  )]
}

read_reference_person_covariates <- function(country) {
  path <- file.path(build_repo, "data", sprintf("HBS_HM_%s.xlsx", country))
  members <- as.data.table(read_excel(path, na = c("NA", "", " ")))
  required <- c("MA04", "COUNTRY", "YEAR", "MA05", "MB03_Recoded_5Classes")
  if (length(setdiff(required, names(members)))) stop("Missing member covariates for ", country)
  members <- members[COUNTRY == country & as.integer(YEAR) == basket_year & MA05 == "Z1"]

  education_field <- intersect(c("MC01A_Recoded_3Categ", "MC01A", "MC01"), names(members))
  if (!length(education_field)) return(data.table())
  education_field <- education_field[[1]]
  code <- trimws(as.character(members[[education_field]]))
  if (education_field == "MC01A_Recoded_3Categ") {
    education <- fcase(
      code == "2", "Low", code == "3", "Medium", code == "5", "High",
      default = NA_character_
    )
  } else if (education_field == "MC01A") {
    education <- fcase(
      code %in% c("10", "Z1", "Z2"), "Low",
      code %in% c("Z3", "Z4"), "Medium",
      code %in% c("Z5", "Z6", "Z7", "Z8"), "High",
      default = NA_character_
    )
  } else {
    education <- fcase(
      code %in% c("0", "1", "2"), "Low",
      code %in% c("3", "4"), "Medium",
      code %in% c("5", "6", "7", "8"), "High",
      default = NA_character_
    )
  }

  age_code <- tolower(trimws(as.character(members$MB03_Recoded_5Classes)))
  age <- fcase(
    age_code %in% c("0_14", "15_29"), "Under 30",
    age_code == "30_44", "30--44",
    age_code == "45_59", "45--59",
    age_code == "60_inf", "60 or over",
    default = NA_character_
  )
  data.table(
    household_id = paste(country, basket_year, members$MA04, sep = "_"),
    age = age,
    education = education
  )
}

weighted_quantile <- function(x, w, probs) {
  ok <- is.finite(x) & is.finite(w) & w > 0
  x <- x[ok]
  w <- w[ok]
  ord <- order(x)
  x <- x[ord]
  cumulative_weight <- cumsum(w[ord]) / sum(w)
  vapply(probs, function(p) x[which(cumulative_weight >= p)[1]], numeric(1))
}

annual <- as.data.table(readRDS(inflation_cache))
annual <- annual[
  year == inflation_year &
    method == "ras_expenditure_annual_index_v1_exclude_041_042"
]
countries <- sort(unique(annual$country))

households <- rbindlist(lapply(countries, read_household_covariates), use.names = TRUE)
persons <- rbindlist(lapply(countries, read_reference_person_covariates), use.names = TRUE, fill = TRUE)
annual <- households[annual, on = "household_id", nomatch = 0]
annual <- persons[annual, on = "household_id", nomatch = 0]

annual[, residence := fcase(
  density_code == "1", "Urban",
  density_code == "2", "Intermediate",
  density_code == "3", "Rural",
  default = NA_character_
)]
annual[, household_size_group := fcase(
  household_size == 1, "1 person",
  household_size == 2, "2 people",
  household_size == 3, "3 people",
  household_size == 4, "4 people",
  household_size >= 5, "5+ people",
  default = NA_character_
)]
annual[, income_quintile := paste0("Q", income_quintile_num)]

# Use one complete-case sample in every panel. The Netherlands drops because
# education is not available, matching the paper's saturated R-squared sample.
plot_dt <- annual[
  is.finite(mean_inflation) & is.finite(weight) & weight > 0 &
    income_quintile_num %in% 1:5 & !is.na(age) & !is.na(residence) &
    !is.na(education) & !is.na(household_size_group)
]
if (!nrow(plot_dt)) stop("No complete 2022 observations available.")

# Remove the national mean before pooling countries. Survey weights define each
# country's household distribution; annual HICP weights aggregate countries.
country_statistics_path <- file.path(
  build_repo, "outputs", "hbs_monthly_inflation_2021_2025",
  "country_monthly_mean_percentiles.csv"
)
if (!file.exists(country_statistics_path)) stop("Missing country weights: ", country_statistics_path)
country_weights <- unique(fread(country_statistics_path)[
  year == inflation_year & country %in% unique(plot_dt$country),
  .(country, country_weight = normalized_country_weight)
])
if (nrow(country_weights) != uniqueN(plot_dt$country)) stop("Incomplete 2022 country weights.")
country_weights[, country_weight := country_weight / sum(country_weight)]
plot_dt <- country_weights[plot_dt, on = "country"]
plot_dt[, pooled_weight := country_weight * weight / sum(weight), by = country]
plot_dt[, national_mean := weighted.mean(mean_inflation, weight), by = country]
plot_dt[, centered_inflation := mean_inflation - national_mean]

plot_dt[, income_quintile := factor(income_quintile, levels = paste0("Q", 1:5))]
plot_dt[, age := factor(age, levels = c("Under 30", "30--44", "45--59", "60 or over"))]
plot_dt[, residence := factor(residence, levels = c("Rural", "Intermediate", "Urban"))]
plot_dt[, education := factor(education, levels = c("Low", "Medium", "High"))]
plot_dt[, household_size_group := factor(
  household_size_group,
  levels = c("1 person", "2 people", "3 people", "4 people", "5+ people")
)]

x_limits <- weighted_quantile(
  plot_dt$centered_inflation, plot_dt$pooled_weight, c(0.005, 0.995)
)
x_pad <- 0.04 * diff(x_limits)
x_limits <- x_limits + c(-x_pad, x_pad)
grid_x <- seq(x_limits[[1]], x_limits[[2]], length.out = 512L)

weighted_density <- function(dt, variable, bandwidth = 0.32) {
  groups <- levels(dt[[variable]])
  rbindlist(lapply(groups, function(group_name) {
    subset <- dt[as.character(get(variable)) == group_name]
    weights <- subset$pooled_weight / sum(subset$pooled_weight)
    estimate <- density(
      subset$centered_inflation,
      weights = weights,
      bw = bandwidth,
      from = x_limits[[1]], to = x_limits[[2]], n = length(grid_x)
    )
    data.table(
      x = estimate$x,
      density = estimate$y,
      group = factor(group_name, levels = groups)
    )
  }))
}

palette_5 <- c("#173F5F", "#2878B5", "#49A5A5", "#E0A12E", "#C64B40")
palette_4 <- c("#173F5F", "#3B82B4", "#D79B2E", "#B8433F")
palette_3 <- c("#2878B5", "#777777", "#C64B40")

make_panel <- function(variable, title, palette) {
  density_dt <- weighted_density(plot_dt, variable)
  ggplot(density_dt, aes(x = x, y = density, colour = group)) +
    geom_vline(xintercept = 0, colour = "grey72", linewidth = 0.35) +
    geom_line(linewidth = 0.72, alpha = 0.95) +
    scale_colour_manual(values = palette, name = NULL) +
    coord_cartesian(xlim = x_limits, expand = FALSE) +
    labs(title = title, x = NULL, y = NULL) +
    theme_minimal(base_family = "sans", base_size = 9.5) +
    theme(
      plot.title = element_text(face = "bold", size = 10.5, margin = margin(b = 4)),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = "grey90", linewidth = 0.3),
      axis.text = element_text(colour = "grey25"),
      legend.position = "bottom",
      legend.text = element_text(size = 7.8),
      legend.key.width = unit(11, "pt"),
      legend.spacing.x = unit(2, "pt"),
      plot.margin = margin(5, 7, 3, 7)
    )
}

p_income <- make_panel("income_quintile", "A. Income quintile", palette_5)
p_age <- make_panel("age", "B. Age of reference person", palette_4)
p_residence <- make_panel("residence", "C. Residence", palette_3)
p_education <- make_panel("education", "D. Education of reference person", palette_3)
p_size <- make_panel("household_size_group", "E. Household size", palette_5)

output_base <- file.path(paper_repo, "fig", "fig_household_inflation_distributions_five_groups_2022")

draw_figure <- function() {
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(
    nrow = 3, ncol = 6,
    heights = unit(c(3, 3, 0.3), c("null", "null", "in")),
    widths = unit(rep(1, 6), "null")
  )))
  print(p_income, vp = viewport(layout.pos.row = 1, layout.pos.col = 1:2))
  print(p_age, vp = viewport(layout.pos.row = 1, layout.pos.col = 3:4))
  print(p_residence, vp = viewport(layout.pos.row = 1, layout.pos.col = 5:6))
  print(p_education, vp = viewport(layout.pos.row = 2, layout.pos.col = 2:3))
  print(p_size, vp = viewport(layout.pos.row = 2, layout.pos.col = 4:5))
  grid.text(
    "Deviation from national mean (percentage points)",
    vp = viewport(layout.pos.row = 3, layout.pos.col = 1:6),
    gp = gpar(fontsize = 9.5, col = "grey25")
  )
  popViewport()
}

pdf(paste0(output_base, ".pdf"), width = 12.2, height = 6.3, useDingbats = FALSE, version = "1.4")
draw_figure()
dev.off()
png(paste0(output_base, ".png"), width = 12.2, height = 6.3, units = "in", res = 220, type = "cairo")
draw_figure()
dev.off()

summarize_means <- function(variable, panel_name) {
  result <- plot_dt[
    , .(mean = weighted.mean(centered_inflation, pooled_weight)),
    by = .(group = get(variable))
  ]
  result[, panel := panel_name]
  setcolorder(result, c("panel", "group", "mean"))
  result
}
group_means <- rbindlist(list(
  summarize_means("income_quintile", "income"),
  summarize_means("age", "age"),
  summarize_means("residence", "residence"),
  summarize_means("education", "education"),
  summarize_means("household_size_group", "household size")
), use.names = TRUE)

cat("Households:", uniqueN(plot_dt$household_id), "\n")
cat("Countries (", uniqueN(plot_dt$country), "): ", paste(sort(unique(plot_dt$country)), collapse = ", "), "\n", sep = "")
cat("Display range:", sprintf("%.2f to %.2f pp", x_limits[[1]], x_limits[[2]]), "\n")
print(group_means)
