##	Define the parameters to create the pseudo-random charges
set.seed(32574)
myMean = 500000
mySD = 50000


##	Create a vector of charges with a normal distribution plus two additional values
charges <- c(rnorm(178, mean = myMean, sd = mySD), 587750, 412250)


##	Plot a histogram of charge frequency
myHist <- hist(charges, breaks = 15)
plot(myHist, col = "red", ylim = c(0, 30), main = "Charges Last 180 Days", xlab = "Charge Amount")


##	Add a bell curve to the histogram
myX <- seq(min(charges), max(charges), length.out = 100)
normal <- dnorm(myX, mean = myMean, sd = mySD)
multiplier <- mean(myHist$counts / myHist$density, na.rm = TRUE)
lines(myX, normal * multiplier, col = "blue", lwd = 2)
