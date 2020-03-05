/***
* Name: playground2
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model playground2

/* Insert your model definition here */

global {
	file rain_tif <- file("../../../data/gis/rain_grid.tif");
	file catchment_shape <- file("../../../data/gis/catchment_shape.shp");
	file rain_csv <- file("../../../data/rain/single.csv");
	file elevation_tif <- file("../../../data/gis/elevation_sample.tif");
	file elevation_shape <- file("../../../data/gis/small_shape.shp");
	
	geometry shape <- envelope(elevation_shape);
	
	float max_height;
	float min_height;
	
	init {
		create cell from: elevation_shape {
			height <- float(self get "DN");
		}
		list altitudes <- cell collect each.height;
		max_height <- max(altitudes);
		min_height <- min(altitudes);
	}
}


species cell {
	float height;
	
	aspect default {
		int colour_val <- int((height-min_height)/(max_height-min_height)*255);
		draw shape color: rgb(colour_val*matrix(1, 1, 1)) border: rgb((255-colour_val)*matrix(1, 1, 1)) depth: height;
	}
}

experiment test type: gui {
	output {
		display main type: opengl{
			species cell;
		}
	}
}