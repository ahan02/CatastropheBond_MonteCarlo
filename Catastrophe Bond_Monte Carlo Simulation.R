#Read Data File
filepath <- "Directory"
tornado.dat <- read.table(filepath,sep=",", header=TRUE)

filepath2 <- "Directory"
exposure.dat <- read.table(filepath2,sep=",",header=TRUE)

#Converts latitude and longitude coordinates into miles
exposure.dat$Longitude <- (exposure.dat$Longitude-(-97.520943))/0.017045
exposure.dat$Latitude <- (exposure.dat$Latitude-35.291034)/0.014267

#Narrow Exposure Data to Desired Dimensions and Plot
exposure.dat2<-exposure.dat[exposure.dat$Longitude>=0,]
exposure.dat2<-exposure.dat2[exposure.dat2$Longitude<=6.22,]
exposure.dat2<-exposure.dat2[exposure.dat2$Latitude >=0,]
exposure.dat2<-exposure.dat2[exposure.dat2$Latitude<=5.6,]

summary(exposure.dat2)

library(rgl)
plot3d(exposure.dat2$Longitude,exposure.dat2$Latitude,exposure.dat2$ACTUALVAL)

#Extract Annuals Frequencies and Derive Average Intense Tornado Proportion
tornado.freq <- as.data.frame(table(tornado.dat$Year))
library(gdata)
tornado.freq <- rename.vars(tornado.freq,from="Var1",to="Year")
ts.plot(tornado.freq)

Year <- tornado.dat$Year[tornado.dat$Fscale >=3]

tornado.freq2 <- as.data.frame(table(Year),responseName="Freq")

tornado.freq3 <- merge(tornado.freq,tornado.freq2,all.x=TRUE,by="Year")

tornado.freq3[is.na(tornado.freq3)] <- 0

Perc.intense=NULL
for (i in 1:64) {  
  Perc.intense[i] <- tornado.freq3[i,3]/tornado.freq3[i,2] 
}

tornado.freq3 <- cbind(tornado.freq3,Perc.intense)

p.intense <- mean(tornado.freq3$Perc.intense)

OKsqmi <- 69960
Mooresqmi <- 21.9

p.intense.Moore <- p.intense*Mooresqmi/OKsqmi

hist(tornado.freq3$Freq.y, breaks=10)
hist(tornado.freq3$Perc.intense, breaks=10)


#Extract StartLat,StartLong,EndLong,EndLong in order to calculate slope
StartLat<-tornado.dat$StartLat[tornado.dat$Fscale>=3]
StartLong<-tornado.dat$StartLong[tornado.dat$Fscale>=3]
EndLat<-tornado.dat$EndLat[tornado.dat$Fscale>=3]
EndLong<-tornado.dat$EndLong[tornado.dat$Fscale>=3]

#Determines abnormal parameter values
i <- EndLat==0
k<-(1:length(EndLat))[i]
tornado.dat2
tornado.dat2[k,]
tornado.dat2[59,]
tornado.dat2[71,]

#Displays the 6 tornados were the end longitude was greater than the starting
j <- EndLong < StartLong
tornado.dat2[j,]

#Calculates historical slope and reassigns undefined slopes to zero
Slope.hist <- (EndLong-StartLong) / (EndLat-StartLat)
Slope.hist[Slope.hist==Inf] <- 0
Slope.hist[Slope.hist=="NaN"] <- 0

#Extracts historical length and width
Length.hist <- tornado.dat2$Length
Width.hist <- tornado.dat2$Width


#Loss Calculating Function
Loss.fct <- function(x1,y1,m,length,width) {
  x2 <- (length/sqrt(1+m^2)) + x1
  y2 <- (m*length/sqrt(1+m^2)) + y1
  g.x <- function (x) {
    m*(x-x1) + y1 + width/2
  }
  h.x <- function (x) {
    m*(x-x1) + y1 - width/2
  }
  temp.dat<-exposure.dat2[exposure.dat2$Longitude>=x1, ]
  temp.dat<-temp.dat[temp.dat$Longitude<=x2, ]
  temp.dat<-temp.dat[temp.dat$Latitude>=h.x(temp.dat$Longitude), ]
  temp.dat<-temp.dat[temp.dat$Latitude<=g.x(temp.dat$Longitude), ]
  sum(temp.dat$ACTUALVAL)
}

#Test of Loss Function for one event
test<-Loss.fct(1,2,0.5,1,0.5)

#Sampling of start points, slope, length, and width
set.seed(1237)
x1 <- runif(10000,min=0,max=6.22)
y1 <- runif(10000,min=0,max=5.6)
plot(x1,y1,pch=20)

m <- sample(Slope.hist,10000,replace=TRUE)

length=NULL
width=NULL
for (i in 1:10000) {
  j <- sample(1:272,1)
  length[i]<-Length.hist[j]
  width[i]<-Width.hist[j]
}

width <- width/1760 #Convert width to miles

#Calculation of the loss distribution
Loss=NULL
for (j in 1:length(x1)) {
  Loss[j] <- Loss.fct(x1[j],y1[j],m[j],length[j],width[j])
}

hist(Loss,breaks=100)

#Calculation of bond price (no limit, no attachment)
Exp.Loss <- mean(Loss)*p.intense.Moore
risk.free <- 0.03
Fair.Value <- Exp.Loss/(1+risk.free)
C <- (mean(Loss)/(1+risk.free)) - Fair.Value
C

IRR <- mean(Loss)/C
IRR

#Loss Distribution Analysis
plot(exposure.dat2$Longitude,exposure.dat2$Latitude,pch=20,
     main="Map of the City of Moore, OK")

summary(Loss)
print(paste(mean(Loss),sqrt(var(Loss)/10000),
            sqrt(var(Loss)/10000)/mean(Loss)))
hist(Loss,breaks=100)

index<-Loss==max(Loss)
(1:10000)[index]

x2 <- (length[9570]/sqrt(1+m[9570]^2)) + x1[9570]
y2 <- (m[9570]*length[9570]/sqrt(1+m[9570]^2)) + y1[9570]
g.x <- function (x) {
  m[9570]*(x-x1[9570]) + y1[9570] + width[9570]/2
}
h.x <- function (x) {
  m[9570]*(x-x1[9570]) + y1[9570] - width[9570]/2
}
temp.dat<-exposure.dat2[exposure.dat2$Longitude>=x1[9570], ]
temp.dat<-temp.dat[temp.dat$Longitude<=x2, ]
temp.dat<-temp.dat[temp.dat$Latitude>=h.x(temp.dat$Longitude), ]
temp.dat<-temp.dat[temp.dat$Latitude<=g.x(temp.dat$Longitude), ]

plot(exposure.dat2$Longitude,exposure.dat2$Latitude,pch=20,
     main="Max Loss: $695.5 Million")
abline(v=x1[9570],col='red')
abline(v=x2,col='red')
abline(g.x(0),m[9570],col='red')
abline(h.x(0),m[9570],col='red')

plot(temp.dat$Longitude,temp.dat$Latitude,pch=20,
     main="Max Loss: $695.5 Million")
abline(v=x1[9570],col='red')
abline(v=x2,col='red')
abline(g.x(0),m[9570],col='red')
abline(h.x(0),m[9570],col='red')

Loss[10000]
x2 <- (length[10000]/sqrt(1+m[10000]^2)) + x1[10000]
y2 <- (m[10000]*length[10000]/sqrt(1+m[10000]^2)) + y1[10000]
g.x <- function (x) {
  m[10000]*(x-x1[10000]) + y1[10000] + width[10000]/2
}
h.x <- function (x) {
  m[10000]*(x-x1[10000]) + y1[10000] - width[10000]/2
}
temp.dat<-exposure.dat2[exposure.dat2$Longitude>=x1[10000], ]
temp.dat<-temp.dat[temp.dat$Longitude<=x2, ]
temp.dat<-temp.dat[temp.dat$Latitude>=h.x(temp.dat$Longitude), ]
temp.dat<-temp.dat[temp.dat$Latitude<=g.x(temp.dat$Longitude), ]

plot(exposure.dat2$Longitude,exposure.dat2$Latitude,pch=20,
     main="Sample Loss: $1.48 Million")
abline(v=x1[10000],col='red')
abline(v=x2,col='red')
abline(g.x(0),m[10000],col='red')
abline(h.x(0),m[10000],col='red')

plot(temp.dat$Longitude,temp.dat$Latitude,pch=20,
     main="Sample Loss: $1.48 Million")
abline(v=x1[10000],col='red')
abline(v=x2,col='red')
abline(g.x(0),m[10000],col='red')
abline(h.x(0),m[10000],col='red')
