# Generate slide 9 country-gap bar plot from the values reported in slides.tex.
root <- normalizePath(".", mustWork = TRUE)
out <- file.path(root, "fig", "slide9_country_gaps_excl_pt_fi.pdf")

country <- c("Spain", "France", "Austria", "Cyprus", "Euro area", "Netherlands",
             "Germany", "Malta", "Italy", "Slovenia", "Slovakia", "Ireland",
             "Lithuania", "Estonia", "Latvia")
gap <- c(0.1, 0.2, 0.4, 0.7, 0.9, 1.2, 1.3, 1.6, 2.1, 2.4, 2.7, 3.8, 4.6, 7.5, 9.5)

navy <- "#24364B"; orange <- "#E07A3F"; grid <- "#EEF1F3"
pdf(out, width = 11.4, height = 5.8, family = "sans", useDingbats = FALSE)
par(mar = c(6.5, 4.8, 0.2, 0.4), fg = navy, col.axis = navy, col.lab = navy,
    family = "sans", las = 1, bty = "n", cex.axis = 1.28, cex.lab = 1.45)
bp <- barplot(gap, names.arg = country, horiz = FALSE, ylim = c(0, 9.85), las = 2,
              col = ifelse(country == "Euro area", orange, navy), border = NA,
              axes = FALSE, ylab = "Inflation gap (percentage points)", cex.names = 1.14)
axis_breaks <- c(0, 2, 4, 6, 8)
abline(h = axis_breaks, col = grid, lwd = 0.55)
axis(2, at = axis_breaks, col = NA, col.axis = navy, tick = FALSE, las = 1)
inside <- gap >= 9
text(bp[!inside], gap[!inside] + 0.13, sprintf("%.1f", gap[!inside]), pos = 3,
     font = 2, col = navy, cex = 1.08)
text(bp[inside], gap[inside] - 0.28, sprintf("%.1f", gap[inside]),
     font = 2, col = "white", cex = 1.08)
dev.off()
