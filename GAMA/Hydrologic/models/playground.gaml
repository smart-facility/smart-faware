/***
* Name: playground2
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model playground2

/* Insert your model definition here */

global {
	file elevation_tif <- file("../../../data/gis/DEM/urban_grid.tif");
	file impervious_shape <- file("../../../data/gis/impervious_shape.shp");
	
	geometry shape <- envelope(elevation_tif);
	float step <- 15#mn;
	
	float LAG_PARAM <- 1.61;
	
	init {
		ask [land[10506], land[10507], land[10403]] {
			//source <- true;
			do take_water(10000.0);
		}
	}
	
	reflex rain {
		ask land parallel: true {
			do take_water(20#mm*shape.area);
		}
	}
	
	reflex update_water {
		loop cell over: shuffle(land) sort_by each.height {
			ask cell {do give_water;}
		}
	}
}

grid land file: elevation_tif neighbors: 8 {
	float altitude;
	float height;
	bool source;
	float constant <- LAG_PARAM*((self.shape.area/#km^2)^0.57)#h;
	
	init {
		altitude <- grid_value;
		create water from: [shape] {
			location <- location + {0, 0, altitude};
		}
		height <- altitude + water[0].level;
	}
	
	action give_water {
		float storage <- water[0].storage;
		list<land> flow_to <- neighbors where (each.height < height);
		float total_diff <- sum(flow_to collect (height - each.height));
		float flow_amm <- min([storage, step*(storage/constant)^(1/0.77)]);
		
		ask flow_to {
			float proportion <- (myself.height - height)/total_diff;
			do take_water(proportion*flow_amm);
		}
		
		if !source {
			do take_water(-flow_amm);
		}
	}
	
	action take_water (float amount) {
		water[0].storage <- water[0].storage + amount;
		water[0].level <- water[0].storage/shape.area;
		height <- altitude + water[0].level;
	}
	
	species water {
		float storage min: 0.0;
		float level;
	}
	
	aspect default {
		draw shape color: #lightgreen depth: altitude;
		ask water {
			draw shape color: rgb(0, 0, 255, int((((bool(level) ? 0.02 : 0) + level/2.5))*255)) depth: level;
		}
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species land;
			graphics "impervious" position: {0, 0, 0.2} {
				loop imp over: impervious_shape{
					draw imp color: #darkgrey;
				}
			}
		}
	}
}