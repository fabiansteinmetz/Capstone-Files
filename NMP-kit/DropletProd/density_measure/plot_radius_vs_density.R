library(latex2exp)

d <- read.table(
  "~/Documents/2026:2027/Capstone/NMP-kit/DropletProd/density_measure/shrinking_sphere_density.dat",
  comment.char = "#",
  col.names = c("r", "count", "rho")
)

plot(d$r, d$rho,
     type = "l",
     lwd = 2,
     xlab = "sphere radius (Å)",
     ylab = "density (g/cm³)",
     main = TeX(r'(Cumulative density vs. sphere radius)'),
     font.main = 1)

abline(v = 18, lty = 2, col = "red", lwd = 1.5)
abline(v = 53, lty = 2, col = "red", lwd = 1.5)

grid()

# Save to file
png("~/Documents/2026:2027/Capstone/NMP-kit/DropletProd/output_prod_071026/density_profile.png", width = 900, height = 600, res = 150)

plot(d$r, d$rho,
     type = "l",
     lwd = 2,
     xlab = "sphere radius (Å)",
     ylab = "density (g/cm³)",
     main = "Cumulative density vs. sphere radius")

abline(v = 25, lty = 2, col = "red", lwd = 1.5)
abline(v = 50, lty = 2, col = "red", lwd = 1.5)

grid()

