#!/usr/bin/env Rscript

# France, 2022: survey-weighted household inflation distributions for Q1 and Q5.
# Usage: Rscript scripts/generate_slide11_fr_distribution_2022.R path/to/FR_cache.rds

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Pass the restricted French household-inflation RDS as the first argument.")

input <- normalizePath(args[[1]], mustWork = TRUE)
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else
  "scripts/generate_slide11_fr_distribution_2022.R"
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
output <- file.path(root, "fig", "slide11_fr_household_inflation_q1_q5_2022.pdf")

d <- readRDS(input)
required <- c("year", "mean_inflation", "equivalised_income", "weight")
if (length(setdiff(required, names(d)))) stop("The input cache lacks required columns.")
if ("country" %in% names(d)) d <- d[d$country == "FR", ]

weighted_quantile <- function(x, w, probs) {
  ok <- is.finite(x) & is.finite(w) & w > 0
  x <- x[ok]
  w <- w[ok]
  o <- order(x)
  x <- x[o]
  w <- w[o]
  cw <- cumsum(w) / sum(w)
  vapply(probs, function(p) x[which(cw >= p)[1]], numeric(1))
}

# Follow the source pipeline: define HA10-weighted income quintiles on the
# complete annual file before selecting the comparison year.
income_rows <- d
breaks <- weighted_quantile(
  income_rows$equivalised_income,
  income_rows$weight,
  seq(0.2, 0.8, by = 0.2)
)
d$quintile <- cut(
  d$equivalised_income,
  breaks = c(-Inf, breaks, Inf),
  labels = paste0("Q", 1:5),
  include.lowest = TRUE
)

z <- d[d$year == 2022 & d$quintile %in% c("Q1", "Q5"), ]
z <- z[is.finite(z$mean_inflation) & is.finite(z$weight) & z$weight > 0, ]

weighted_mean <- function(g) weighted.mean(g$mean_inflation, g$weight)
means <- c(Q1 = weighted_mean(z[z$quintile == "Q1", ]),
           Q5 = weighted_mean(z[z$quintile == "Q5", ]))

weighted_density <- function(g, from = 0, to = 14) {
  bandwidth <- bw.nrd0(g$mean_inflation)
  density(
    g$mean_inflation,
    weights = g$weight / sum(g$weight),
    bw = bandwidth,
    from = from,
    to = to,
    n = 1024
  )
}
d1 <- weighted_density(z[z$quintile == "Q1", ])
d5 <- weighted_density(z[z$quintile == "Q5", ])

navy <- "#2E4057"
teal <- "#048A81"
orange <- "#E07A3F"
soft_white <- "#FAFAFA"

pdf(output, width = 10.8, height = 5.2, family = "sans", useDingbats = FALSE)
par(mar = c(4.5, 5.2, 0.4, 0.6), fg = navy, col.axis = navy,
    col.lab = navy, family = "sans", bty = "n", las = 1,
    cex.axis = 1.62, cex.lab = 1.72)
ymax <- max(d1$y, d5$y) * 1.18
plot(d1$x, d1$y, type = "n", xlim = c(0, 14), ylim = c(0, ymax),
     xlab = "Household inflation (%)", ylab = "Weighted density", yaxt = "n")
polygon(c(d1$x, rev(d1$x)), c(d1$y, rep(0, length(d1$y))),
        col = adjustcolor(teal, alpha.f = 0.20), border = NA)
polygon(c(d5$x, rev(d5$x)), c(d5$y, rep(0, length(d5$y))),
        col = adjustcolor(orange, alpha.f = 0.18), border = NA)
lines(d1$x, d1$y, col = teal, lwd = 3)
lines(d5$x, d5$y, col = orange, lwd = 3)
abline(v = means["Q1"], col = teal, lwd = 2, lty = 2)
abline(v = means["Q5"], col = orange, lwd = 2, lty = 2)
text(means["Q1"] - 0.10, ymax * 0.96, sprintf("Q1 mean: %.1f%%", means["Q1"]),
     col = teal, adj = 1, font = 2, cex = 1.12)
text(means["Q5"] + 0.10, ymax * 0.86, sprintf("Q5 mean: %.1f%%", means["Q5"]),
     col = orange, adj = 0, font = 2, cex = 1.12)
legend("topright", legend = c("Q1", "Q5"), col = c(teal, orange),
       lwd = 3, bty = "n", horiz = TRUE, cex = 1.62)
dev.off()

# Check the five-quintile survey-weighted law of total variance used on slide 11.
y <- d[d$year == 2022 & is.finite(d$mean_inflation) &
         is.finite(d$weight) & d$weight > 0 & !is.na(d$quintile), ]
overall_mean <- weighted.mean(y$mean_inflation, y$weight)
group_means <- tapply(seq_len(nrow(y)), y$quintile, function(i)
  weighted.mean(y$mean_inflation[i], y$weight[i]))
between <- weighted.mean((group_means[as.character(y$quintile)] - overall_mean)^2,
                         y$weight)
within <- weighted.mean((y$mean_inflation -
                          group_means[as.character(y$quintile)])^2, y$weight)
total <- weighted.mean((y$mean_inflation - overall_mean)^2, y$weight)

message(sprintf("Q1 mean: %.4f; Q5 mean: %.4f", means["Q1"], means["Q5"]))
message(sprintf("Variance: between %.4f + within %.4f = total %.4f",
                between, within, total))
message("Exported: ", output)
