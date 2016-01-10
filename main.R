# Hakken en zagen
# Mark ten Vregelaar and Jos Goris
# 8 January 2016
# This script results in 4 maps: RGB ls 5, RGB ls 8, NDVI ls 5 and ls8 and NDVI differnce in new window
# It writes the ouputs to the output file

# Start with empty environment
rm(list=ls())

# Get required libraries
library(raster)
library(rgdal)
library(rasterVis)

# Read R Code from function in map R
source("R/cloud_remover.R")
source("R/calc_NDVI.R")

# Download the landsat data from drop box
download.file(url="https://www.dropbox.com/s/akb9oyye3ee92h3/LT51980241990098-SC20150107121947.tar.gz?dl=0", 
				 destfile="data/LT51980241990098-SC20150107121947.tar.gz", mode="wget")
download.file(url="https://www.dropbox.com/s/i1ylsft80ox6a32/LC81970242014109-SC20141230042441.tar.gz?dl=0", 
				 destfile="data/LC81970242014109-SC20141230042441.tar.gz", mode="wget")

# Extract the files from the archive
untar("data/LT51980241990098-SC20150107121947.tar.gz",exdir = "./data")
untar("data/LC81970242014109-SC20141230042441.tar.gz",exdir = "./data")

# List the landsat 5 and landsat 8 files
landsat5list<-list.files(path='data/',pattern = 'LT51+.+tif$', full.names=TRUE)
landsat8list <-list.files(path='data/',pattern = 'LC8+.+tif$' , full.names=TRUE)
# Stack the files
landsat5<-stack(landsat5list)
landsat8<-stack(landsat8list)

# Remove fmask layer from the Landsat stacks

cfmask_ls5 <- landsat5[['LT51980241990098KIS00_cfmask']]
landsat5_no_cf <- dropLayer(landsat5, 1)

cfmask_ls8 <- landsat8[['LC81970242014109LGN00_cfmask']]
landsat8_no_cf <- dropLayer(landsat8, 1)

# Change cloud pixels to NA
ls5CloudFree<-cloud_remover(landsat5_no_cf,cfmask_ls5)
ls8CloudFree<-cloud_remover(landsat8_no_cf,cfmask_ls8)

# Save results to output
writeRaster(ls5CloudFree, filename="./output/ls5CloudFree.grd", datatype='FLT4S' ,overwrite=TRUE)
writeRaster(ls8CloudFree, filename="./output/ls8CloudFree.grd", datatype='FLT4S' ,overwrite=TRUE)

# Visualization of the intermediary outputs
plotRGB(ls5CloudFree,5,4,3,stretch='lin')
plotRGB(ls8CloudFree,4,3,2,stretch='lin')
names(landsat8)

# Calculate NDVI
ndvils8 <- overlay(x=ls8CloudFree[[6]], y=ls8CloudFree[[5]], fun=calc_NDVI)
ndvils5 <- overlay(x=ls5CloudFree[[7]], y=ls5CloudFree[[6]], fun=calc_NDVI)

# Calculate the difference  in NDVI between ls 5 and ls 8. ALso get the extent of combined area
difference<- ndvils5 - ndvils8

# Save the raster with difference in NDVI between 1990 and 2014
writeRaster(difference, filename="./output/NDVIdifference.grd", datatype='FLT4S' ,overwrite=TRUE)

# mask rasters to same extent and save result
ndvils5_cr<-crop(ndvils5,bbox(difference),filename="./output/NDVI_ls5.grd", datatype='FLT4S' ,overwrite=TRUE)
ndvils8_cr<-crop(ndvils8,bbox(difference),filename="./output/NDVI_ls8.grd", datatype='FLT4S' ,overwrite=TRUE)

# Plot the 2 NDVI rasters with same legend
levelplot(stack(ndvils5_cr, ndvils8_cr), col.regions = colorRampPalette(c("red",'yellow', "green"))(255),colorkey = list(space = "bottom"), 
					labels = 'NDVI',names.attr=c('Landsat 5 1990' ,'Landsat 8 2014'),main='NDVI Wageningen',scales=list(draw=FALSE))

# Plot the NDVI difference between 2014 and 1990 in new window
dev.new()# new graph device
arg <- list(at=c(-0.5,0,0.5), labels=c("-0.5","0"," 0.5"))
plot(difference,axes=T,main= 'NDVI difference wageningen between 2014 and 1990',col= colorRampPalette(c("green",'black', "red"))(255), 
		 breaks = seq(from = -0.75, to = 0.75, length.out = 255),axis.args=arg)
grid() #plot grid
box() # plot box
mtext(side = 1, "X (meters)", line = 2.5, cex=1.1) # plot X text
mtext(side = 2, "Y (meters)", line = 2.5, cex=1.1) #plot Y text
mtext(side = 3, line = 0," green: NDVI increase, red: NDVI decrease", cex = 1) # add text on values
legend("topright", legend = " Projection\n utm zone 31\n datum=WGS84"
			 ,cex = 0.7, bg = NULL,bty = "n") #plot projection info


