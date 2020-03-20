model playground

global {
	int downstream_id <- 13;
	file upstream_shape <- file("../../../data/gis/surveying/upstream"+string(downstream_id)+".000000.shp");
	file downstream_shape <- file("../../../data/gis/surveying/downstream"+string(downstream_id)+".000000.shp");
	file raster <- file("../../../data/gis/surveying/raster"+string(downstream_id)+".000000.tif");
	
	geometry shape <- envelope(raster);
	
	init {
		create catchment from: upstream_shape {
			colour <- rgb(rnd(255), rnd(255), rnd(255));
		}
		
		create catchment from: downstream_shape {
			colour <- #blue;
		}
		
		ask catchment {
			ask topography where (each overlaps self) {
				colour <- myself.colour;
			}
		}
	}
}

grid topography file: raster {
	float height;
	rgb colour;
	
	init {
		height <- grid_value;
	}
	
	aspect default {
		draw shape depth: height color: colour;
	}
}

species catchment {
	rgb colour;
	
	aspect default {
		draw shape color: colour;
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species topography;
			//species catchment position: {0, 0, 0.5};
		}
	}
}