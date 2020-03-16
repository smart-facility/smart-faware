/***
* Name: playground2
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model playground2

/* Insert your model definition here */

global {
	file elevation_tif <- file("../../../data/gis/DEM/small_raster.tif");
	file impervious_shape <- file("../../../data/gis/impervious_shape.shp");
	
	geometry shape <- envelope(elevation_tif);
	float step <- 15#mn;
	
	float LAG_PARAM <- 1.61;
	
	init {
		list<land> sources <- [land[10506], land[10507], land[10403]];
		//list<land> sources <- [land[2400], land[2450], land[2451]];
		ask sources {
			source <- true;
			do take_water(1000.0);
		}
	}
	
	reflex update_water when: false{
		list<land> execute_stack <- shuffle(land) sort_by each.height;
		loop count from: 0 to: length(land)-1 {
			list<land> temp_flow;
			ask execute_stack[count] {
				temp_flow <- give_water();
			}
			if count < length(land)-1 {
				if temp_flow != [] {
					list<land> checkers <- temp_flow sort_by each.height;
					int next_index <- count+1;
					if checkers[0].height > execute_stack[next_index].height {
						remove checkers[0] from: execute_stack;
						add checkers[0] to: execute_stack at: next_index;
					}
				}
			}
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
	
	list<land> give_water {
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
		return flow_to;
	}
	
	action take_water (float amount) {
		water[0].storage <- water[0].storage + amount;
		water[0].level <- water[0].storage/shape.area;
		height <- altitude + water[0].level;
	}
	
	species water {
		float storage min: 0.0 max: 2000.0;
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
			graphics "buildings" position: {0, 0, 0.3}{
				loop build over: impervious_shape {
					draw build color: #darkgrey;
				}
			}
		}
	}
}