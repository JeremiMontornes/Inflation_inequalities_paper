# Generate the slide 7 country-gap bar plot for 2022.
# Countries with a negative Q1--Q5 gap are excluded; the euro-area aggregate
# is retained as a highlighted benchmark.
root <- normalizePath(".", mustWork = TRUE)
out <- file.path(root, "fig", "slide7_country_gaps_2022_nonnegative.pdf")

country <- c("France", "Portugal", "Belgium", "Luxembourg", "Malta", "Croatia", "Slovenia",
             "Cyprus", "Euro area", "Germany", "Spain", "Slovakia", "Greece",
             "Italy", "Netherlands", "Ireland", "Lithuania", "Estonia", "Latvia")
gap <- c(0.1, 0.1, 1.9, 0.2, 0.2, 0.3, 0.5, 0.7, 0.9, 0.9, 0.9, 1.1, 1.2,
         1.5, 1.8, 2.8, 3.3, 4.3, 4.6)

ord <- order(gap, country)
country <- country[ord]
gap <- gap[ord]

navy <- "#24364B"; orange <- "#E07A3F"; grid <- "#EEF1F3"
pdf(out, width = 11.4, height = 5.8, family = "sans", useDingbats = FALSE)
par(mar = c(6.8, 4.8, 0.2, 0.4), fg = navy, col.axis = navy, col.lab = navy,
    family = "sans", las = 1, bty = "n", cex.axis = 1.28, cex.lab = 1.42)
bp <- barplot(gap, names.arg = country, horiz = FALSE, ylim = c(0, 5.05), las = 2,
              col = ifelse(country == "Euro area", orange, navy), border = NA,
              axes = FALSE, ylab = "Q1-Q5 inflation gap (pp)", cex.names = 1.02)
axis_breaks <- 0:5
abline(h = axis_breaks, col = grid, lwd = 0.55)
axis(2, at = axis_breaks, col = NA, col.axis = navy, tick = FALSE, las = 1)
text(bp, gap + 0.08, sprintf("%.1f", gap), pos = 3,
     font = 2, col = navy, cex = 0.96)
dev.off()
