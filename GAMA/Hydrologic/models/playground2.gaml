model playground2

global {
	file dem_file <- file("../../../data/gis/DEM/downsampled.tif");
	file catch_shape <- file("../../../data/gis/catchment_shape.shp");
	
	geometry shape <- envelope(dem_file);
	
	init {
		create catchment from: catch_shape {
			colour <- rgb(rnd(255), rnd(255), rnd(255));
		}
		
		ask catchment {
			ask topo overlapping self {
				colour <- myself.colour;
				linked <- myself;
			}
		}
		
		ask topo where (each.linked = nil) {
			do die;
		}
	}
}

species catchment {
	rgb colour;
}

grid topo file: dem_file {
	float height;
	rgb colour <- #black;
	catchment linked;
	
	init {
		height <- grid_value;
	}
	
	aspect default {
		draw shape depth: height color: colour;
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species topo;
		}
	}
}