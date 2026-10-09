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
  "monthly_variance_decomposition_saturated.csv"
)

monthly_results <- fread(data_path)
monthly_results[, date := as.Date(date)]
monthly_results[, month := format(date, "%Y-%m")]
monthly_results[, month := factor(month, levels = month)]

plot_data <- melt(
  monthly_results,
  id.vars = c("date", "month"),
  measure.vars = c("total_variance", "explained_variance"),
  variable.name = "component",
  value.name = "variance"
)
plot_data[, component := factor(
  component,
  levels = c("total_variance", "explained_variance"),
  labels = c("Total variance", "Explained variance")
)]

year_breaks <- monthly_results[format(date, "%m") == "01", month]
year_labels <- format(monthly_results[format(date, "%m") == "01", date], "%Y")

grouped_bar_figure <- ggplot(
  plot_data,
  aes(x = month, y = variance, fill = component)
) +
  geom_col(
    position = position_dodge(width = 0.82),
    width = 0.78,
    colour = "white",
    linewidth = 0.08
  ) +
  scale_fill_manual(
    NULL,
    values = c(
      "Total variance" = "#9DB7CF",
      "Explained variance" = "#1F7A78"
    )
  ) +
  scale_x_discrete(
    breaks = year_breaks,
    labels = year_labels,
    expand = expansion(add = c(0.35, 0.35))
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.04))) +
  labs(x = NULL, y = "Variance (percentage points squared)") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(colour = "grey25"),
    axis.text.y = element_text(colour = "grey25"),
    legend.key.width = grid::unit(1.4, "lines")
  )

output_stem <- file.path(
  paper_root,
  "fig",
  "fig_HBS_monthly_inflation_variance_grouped_bars_2021_2025"
)
ggsave(paste0(output_stem, ".pdf"), grouped_bar_figure,
       width = 10.5, height = 4.8, dpi = 300, bg = "white")
ggsave(paste0(output_stem, ".png"), grouped_bar_figure,
       width = 10.5, height = 4.8, dpi = 300, bg = "white")
