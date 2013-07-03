#####install packages to read data#####
if("sampling" %in% rownames(installed.packages()) == FALSE) {install.packages("sampling")}
require(sampling)

######source population builders and api access#####
source("~/wmata-bus-sampling-in-r/PopulationBuilder.r")

######define sampling frame on the bus route dimension#####
getSamplingFrameNow <- function() {
  RouteSamplingFrame <- busroutes$RouteID[which(busroutes$Has.Downtown.Stops.On.Route == T & busroutes$RouteID %in% unique(NumberOfActiveTripsByRouteIdAndTime$RouteID[which(NumberOfActiveTripsByRouteIdAndTime$Buses.On.Route > 0)]))]
  time <- as.POSIXlt(Sys.time())
  time$sec <- 00
  RouteSamplingFrameNow <- RouteSamplingFrame[which(RouteSamplingFrame %in% NumberOfActiveTripsByRouteIdAndTime$RouteID[which(NumberOfActiveTripsByRouteIdAndTime$Time == time & NumberOfActiveTripsByRouteIdAndTime$Buses.On.Route != 0)])]
  return(RouteSamplingFrameNow)
}

#####function that randomly selects from the sampling frame, all units are sampled over the course of one minute#####
GetDataForSampleOfBusesNow <- function(SampleSize,SamplingFrame) {
  if (SampleSize > 20) {
    stop("Sample Size Will Break API limits")
  }
  else {
    BusesToSample <- sample(x=SamplingFrame,size=SampleSize,replace=F)
    BusSampleData <- NULL
    for (n in BusesToSample) {
      BusSampleData <- rbind(BusSampleData,getbuspositiondata(n))
      Sys.sleep(60/SampleSize)
    }
    BusSampleData$SystemTime <- as.POSIXlt(Sys.time())
    BusSampleData$little_n.Route <- SampleSize
    BusSampleData$big_N.Route <- length(SamplingFrame)
    return(BusSampleData)
  }
}