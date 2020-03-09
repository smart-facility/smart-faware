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
	file elevation_tif <- file("../../../data/gis/small_raster.tif");
	file elevation_shape <- file("../../../data/gis/small_shape.shp");
	
	float source_amount <- 1000.0;
	
	float LAG_PARAM <- 1.61;
	float step <- #mn/10;
	geometry shape <- envelope(elevation_shape);
	
	float max_height;
	float min_height;
	
	init {
		create cell from: elevation_shape {
			height <- float(self get "DN");
			top <- height;
			ask water {
				shape <- host.shape;
				location <- location + {0, 0, host.height};
			}
		}
		ask cell where (int(replace_regex(each.name, "[^1234567890]", "")) in [6451, 6452, 6374]) {
			source <- true;
		}
		list altitudes <- cell collect each.height;
		max_height <- max(altitudes);
		min_height <- min(altitudes);
		ask cell where (each.source) {
			storage <- source_amount;
		}
	}
	
	reflex move_water {
		loop cel over: cell sort_by each.top {
			ask cel {
				list<cell> flow_to <- neighbours where (each.top < top);
								
				if flow_to != [] {
					float total_diff <- sum(top - matrix(flow_to collect each.top));
					float flow_amm <- min([storage, step*(storage/constant)^(1/0.77)]);
				
					ask flow_to {
						storage <- storage + ((myself.top - top)/total_diff)*flow_amm;
						ask water {
							level <- storage/shape.area;
						}
						top <- height + water[0].level;
					}
					
					if !source {
						storage <- storage - flow_amm;
						ask water {
							level <- storage/shape.area;
						}
						top <- height + water[0].level;
					}
				}
			}
		}
	}
}


species cell {
	bool source;
	float height;
	float top <- height;
	float storage min: 0.0 max: 2000.0;
	
	list<cell> neighbours;
	
	float constant <- LAG_PARAM*((self.shape.area/#km^2)^0.57)#h;
	
	init {
		create water {
			level <- 0.0;
		}
		neighbours <- cell where (each overlaps self);
		remove self from: neighbours;
	}
	
	aspect default {
		draw shape color: #lightgreen depth: height;
		//int colour_val <- int((height-min_height)/(max_height-min_height)*255);
		//draw shape color: rgb(colour_val*matrix(1, 1, 1)) border: rgb((255-colour_val)*matrix(1, 1, 1)) depth: height;
		ask water {
			draw shape color: rgb(0, 0, 255, int((((bool(level) ? 0.02 : 0) + level/2.5))*255)) depth: level;
		}
	}
	
	species water {
		float level;
	}
}

experiment test type: gui {
	output {
		display main type: opengl{
			species cell;
		}
	}
}