# Hakken en zagen
# Mark ten Vregelaar and Jos Goris
# 8 January 2016

cloud_remover<- function(raster,clouds) {
	cloud2NA <- function(x, y){
		x[y != 0] <- NA
		return(x)
	}
	
	
	# Apply the function on the two raster objects using overlay
	rasterCloudFree <- overlay(x = raster, y = clouds, fun = cloud2NA)
	return(rasterCloudFree)
}

