# Hakken en zagen
# Mark ten Vregelaar and Jos Goris
# 8 January 2016

#NDVI function 
calc_NDVI <- function(x, y) {
	ndvi <- (y - x) / (x + y)
	return(ndvi)
}