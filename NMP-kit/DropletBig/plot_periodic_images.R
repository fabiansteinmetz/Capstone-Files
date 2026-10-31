# Plots the output of periodic_images.tcl
# d = Euclidean distance from a molecule's centre to the nearest edge of the
#     periodic cell (d < 0: molecule centre lies outside the cell)
library(latex2exp)
d <- read.csv("periodic_images_vmd.csv")

png("periodic_images.png", width = 1600, height = 1000, res = 200)
par(mfrow = c(2, 1), mar = c(4, 8, 1, 1), oma = c(2, 0, 0, 0))

plot(d$time_ns, d$n_out, type = "l", lwd = 1.5, col = "blue4",
     xlab = "", ylab = TeX(r'(No. mols $d<0$ Å)'))

plot(d$time_ns, d$n_near_edge, type = "l", lwd = 1.5, col = "blue4",
     xlab = "time [ns]", ylab = TeX(r'(No. mols $0 \leq d < 12$ Å)'))

mtext("d = Euclidean distance from molecule centre to the nearest cell edge",
      side = 1, outer = TRUE, line = 0.5, cex = 0.8)
dev.off()
