# Direct annual Q1--Q5 inflation-gap comparison for slide 15.
# Values come from the annual observed and policy-counterfactual tables.

root <- normalizePath(".", mustWork = TRUE)
out <- file.path(root, "fig", "slide15_observed_no_policy_q1_q5_gap.pdf")

year <- 2021:2023
observed <- c(0.1, 0.9, 0.0)
policy_effect <- c(-0.1, -0.4, -0.5) # observed minus no-policy gap
no_policy <- observed - policy_effect

navy <- "#24364B"
orange <- "#E07A3F"
gray <- "#E8ECEF"

pdf(out, width = 9.8, height = 4.6, family = "sans", useDingbats = FALSE)
par(mar = c(5.0, 4.4, 0.3, 1.8), fg = navy, col.axis = navy,
    col.lab = navy, family = "sans", bty = "n", las = 1,
    cex.axis = 1.40, cex.lab = 1.52, xpd = NA)

plot(year, observed, type = "n", xlim = c(2020.9, 2023.18),
     ylim = c(-0.05, 1.48), xaxt = "n", yaxt = "n",
     xlab = "", ylab = "Q1-Q5 inflation gap (pp)")
abline(h = c(0, 0.5, 1.0, 1.5), col = gray, lwd = 0.8)
axis(1, at = year, labels = year, tick = FALSE, col = NA, col.axis = navy)
axis(2, at = c(0, 0.5, 1.0, 1.5), tick = FALSE, col = NA,
     col.axis = navy)
abline(h = 0, col = navy, lwd = 0.8)

lines(year, no_policy, col = orange, lwd = 3)
points(year, no_policy, col = orange, bg = "white", pch = 21, lwd = 2, cex = 1.45)
lines(year, observed, col = navy, lwd = 3)
points(year, observed, col = navy, bg = "white", pch = 21, lwd = 2, cex = 1.45)

text(year, no_policy + 0.09, sprintf("%.1f", no_policy), col = orange,
     font = 2, cex = 1.25)
text(year, observed - c(0.10, 0.11, -0.10), sprintf("%.1f", observed),
     col = navy, font = 2, cex = 1.25)

arrow_x <- c(2022.12, 2023.08)
arrows(arrow_x, no_policy[2:3] - 0.04,
       arrow_x, observed[2:3] + 0.04,
       length = 0.10, angle = 25, lwd = 1.8, col = navy)
text(2022.18, mean(c(no_policy[2], observed[2])) - 0.12, "-0.4 pp",
     col = navy, adj = 0, font = 2, cex = 1.22)
text(2022.92, mean(c(no_policy[3], observed[3])) + 0.09, "-0.5 pp",
     col = navy, adj = 1, font = 2, cex = 1.22)

legend(mean(par("usr")[1:2]), par("usr")[3] - 0.30,
       legend = c("No policy", "Observed"),
       col = c(orange, navy), lwd = 3, pch = 21,
       pt.bg = "white", pt.cex = 1.2,
       horiz = TRUE, xjust = 0.5, bty = "n", cex = 1.30)

dev.off()
