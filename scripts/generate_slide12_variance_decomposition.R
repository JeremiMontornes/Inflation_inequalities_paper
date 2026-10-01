#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

script_argument <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- if (length(script_argument)) {
  sub("^--file=", "", script_argument[1])
} else {
  "scripts/generate_slide12_variance_decomposition.R"
}
paper_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
data_path <- file.path(
  dirname(paper_root),
  "build-figures-tables",
  "outputs",
  "hbs_monthly_explained_dispersion",
  "monthly_variance_decomposition.csv"
)

monthly_results <- fread(data_path)
monthly_results[, date := as.Date(date)]

slide_figure <- ggplot(monthly_results, aes(x = date)) +
  geom_ribbon(
    aes(
      ymin = mean - total_standard_deviation,
      ymax = mean + total_standard_deviation,
      fill = "Square root of total variance"
    )
  ) +
  geom_ribbon(
    aes(
      ymin = mean - explained_standard_deviation,
      ymax = mean + explained_standard_deviation,
      fill = "Square root of explained variance"
    )
  ) +
  geom_hline(yintercept = 0, colour = "grey65", linewidth = 0.3) +
  geom_line(aes(y = mean, colour = "Mean"), linewidth = 0.85) +
  scale_fill_manual(
    NULL,
    values = c(
      "Square root of explained variance" = "#48a49d",
      "Square root of total variance" = "#dbe7f1"
    ),
    breaks = c(
      "Square root of explained variance",
      "Square root of total variance"
    )
  ) +
  scale_colour_manual(NULL, values = c("Mean" = "#143b56")) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y",
    limits = range(monthly_results$date),
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  scale_y_continuous(breaks = seq(0, 16, by = 4)) +
  coord_cartesian(ylim = c(0, 16), expand = FALSE) +
  labs(x = NULL, y = "Percentage points") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

output_stem <- file.path(
  paper_root,
  "fig",
  "fig_HBS_monthly_inflation_variance_decomposition_2021_2025_slide"
)
ggsave(paste0(output_stem, ".pdf"), slide_figure,
       width = 9, height = 5.2, dpi = 300, bg = "white")
ggsave(paste0(output_stem, ".png"), slide_figure,
       width = 9, height = 5.2, dpi = 300, bg = "white")
