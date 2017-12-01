##  Generating binomial data

##	Let's get some help!
?rbinom

##	Toss one fair coin five times, and count the number of heads
rbinom(n = 5, size = 1, prob = 0.50);

##	Toss ten fair coins twenty times and count the number of heads
rbinom(n = 20, size = 10, prob = 0.50);

##	Toss ten fair coins 1000 times and count the number of heads
rbinom(n = 1000, size = 10, prob = 0.50);

##	Histogram of 10,000 Tosses Of 10 Fair Coins
hist(rbinom(n = 10000, size = 10, prob = 0.50), col = "red", breaks = 11, main = "10,000 Tosses Of 10 Fair Coins", xlab = "Number Of Heads");

##	Histogram of 10,000 Tosses Of 10 Unfair Coins (p = 0.70)
hist(rbinom(n = 10000, size = 10, prob = 0.70), col = "red", breaks = 11, main = "10,000 Tosses Of 10 Unfair Coins", xlab = "Number Of Heads");



##	Modeling Dr. McCoy's Distribution
hist(rbinom(n = 10000, size = 16, prob = 1.0000 - 0.1055), col = "red", breaks = 17, main = "10,000 Days For Dr. McCoy", xlab = "Number Of Arrivals");

##	Turn off scientific notation
options(scipen = 999);


##	Exact percentages
##	What percentage of the time will exactly 15 out of Dr. McCoy's 16 patients show up for their appointment?
dbinom(x = 15, size = 16, prob = 1.0000 - 0.1055);

##	What are the complete percentages for Dr. McCoy?
dbinom(x = 16:0, size = 16, prob = 1.0000 - 0.1055);

##	Are 16/16 people really going to show up nearly 17% of the time?
(1.0000 - 0.1055) ^ 16;


##	Range percentages
##	What is the probability that more than 14 of the 16 patients show up?
pbinom(q = 14, size = 16, prob = 1.0000 - 0.1055, lower.tail = FALSE);

##	What is the probability that 14 or fewer of the 16 patients show up?
pbinom(q = 14, size = 16, prob = 1.0000 - 0.1055, lower.tail = TRUE);

##	What is the probability that 14 or more of the 16 patients show up?
##	Note that this doesn't fit into our two options above.
##	The non-intuitive solution is that 14 or more is the opposite of 13 or fewer.
1 - pbinom(q = 13, size = 16, prob = 1.0000 - 0.1055, lower.tail = TRUE);


##	Quantile probabilities

##	How many people will show up on the 90th percentile of Dr. McCoy's distribution?
##	This is because We don't want to have more patients than slots more than 10% of days.
qbinom(p = 0.90, size = 16, prob = 1.0000 - 0.1055, lower.tail = TRUE);
##	Another way of thinking about this is that if we allowed even one overbook slot for Dr. McCoy,
##	then we would have more patients than slots on nearly 19% of days.



##	Let's look at Family Medicine instead.
##	What are the complete percentages for Dr. Quinn?
dbinom(x = 32:0, size = 32, prob = 1.0000 - 0.2476);


##	Modeling Dr. Quinn's Distribution
hist(rbinom(n = 10000, size = 32, prob = 1.0000 - 0.2476), col = "red", breaks = 17, main = "10,000 Days For Dr. Quinn", xlab = "Number Of Arrivals");

##	How many people will show up on the 90th percentile of Dr. Quinn's distribution?
qbinom(p = 0.90, size = 32, prob = 1.0000 - 0.2476, lower.tail = TRUE);
##	So we can fairly safely (90%) overbook five slots for Dr. Quinn.
##	Another way of thinking about this is that if we fill all five overbook slots every day,
##	we will only have too many patients on 10% of the days.
