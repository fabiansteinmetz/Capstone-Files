library(latex2exp)

d <- read.table(
  "~/Documents/2026:2027/Capstone/NMP-kit/Slab/output_prod_091026/moving_box_slab.dat",
  comment.char = "#",
  col.names = c("r", "count", "rho")
)

make_plot <- function() {
  plot(d$r, d$rho,
       type = "l",
       lwd  = 2,
       xlab = TeX(r'($L$ (Å))'),
       ylab = TeX(r'(density (g/cm$^3$))'),
       main = TeX(r'(Density of a fixed $r_0 = 25$ Å cube moved along $z$)'))
  abline(v = c(50-12.5), lty = 2, col = "red", lwd = 1.5)
  grid()
}

# On screen
make_plot()

# To file
png("~/Documents/2026:2027/Capstone/NMP-kit/Slab/output_prod_091026/density_profile.png",
    width = 900, height = 600, res = 150)
make_plot()
dev.off()
