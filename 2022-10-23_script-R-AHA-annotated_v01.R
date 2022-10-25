setwd("") # Set working directory

MLIRTdata<-read.csv(file.choose()) # Choose .csv file for MLIRT analyses
View(MLIRTdata) # View data set
# Change order of variables in the data set so that the participant ID and wave variables are in columns 1 and 2 and all items 
# contributing to the metric are adjacent to one another
MLIRTdata<-MLIRTdata[c(1,17,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,
                       25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,
                       42,43,44,45,46,47,48,49,50,51,52,53)] 

install.packages("sirt") # Install the package to run the MLIRT analysis
library(sirt) # Load the library
install.packages("coda") # Install the package to run the MLIRT analysis
library(coda) # Load the library
group <- MLIRTdata$wave # Sets the wave variable as the group identifier - allows the different waves to be included as random effects
# Set the number of burn-in iterations and iterations for all examples
burnin <- 100 ; iter <- 5000

#***
# dat identifies the data frame for the MLIRT analyses and uses items in columns 3-53 to create the latent score (i.e., omitting the first two columns)
# Model 1: no intercept variance, no slopes
mod1 <- sirt::mcmc.2pno.ml( dat=MLIRTdata[,3:53], group=group, est.b.Var="n",
                            burnin=burnin, iter=iter, link="normal",  progress.iter=20  )
options(max.print=1000000) # Remove limits on the amount of information printed in the console (enables the full output to be displayed)
summary(mod1) # Summarise results

#***
# Model 2a: itemwise intercept variance, no slopes
mod2a <- sirt::mcmc.2pno.ml( dat=MLIRTdata[,3:53], group=group, est.b.Var="i",
                             burnin=burnin, iter=iter,link="normal",  progress.iter=20  )
options(max.print=1000000)
summary(mod2a)

#***
# Model 2b: homogeneous intercept variance, no slopes
mod2b <- sirt::mcmc.2pno.ml( dat=MLIRTdata[,3:53], group=group, est.b.Var="j",
                             burnin=burnin, iter=iter,link="normal",  progress.iter=20  )
options(max.print=1000000)
summary(mod2b)

#***
# Model 3: intercept variance and slope variances
#          hierarchical item and slope parameters
mod3 <- sirt::mcmc.2pno.ml( dat=MLIRTdata[,3:53], group=group,
                            est.b.M="h", est.b.Var="i", est.a.M="h", est.a.Var="i",
                            burnin=burnin, iter=iter,link="normal",  progress.iter=20  )
options(max.print=1000000)
summary(mod3)

data4<-mod3$person # Extract person parameter estimates from the final model and assign them to a data set "data4"
View(data4) # View data
range(data4$EAP,na.rm=TRUE) # Returns the range of the estimates

library(scales) # Load the library
dat<-rescale((data4$EAP), to = c(0, 100)) # Transform the latent trait score into a 0-100 scale and assign the results to a data set "dat"
View(dat) # View data
datnew<-round(dat, digits = 0) # Round the values to 0 decimal places and assign the results to a new data set "datnew"
View(datnew) # View data
MLIRTdata$AHA<-datnew # Append the AHA scores to the full data set that was originally imported into R for analyses
View(MLIRTdata) # View data

library(foreign) # Load the library
# Export data set in .dta format
write.dta(MLIRTdata, "[pathname omitted]/MLIRTdata.dta")
