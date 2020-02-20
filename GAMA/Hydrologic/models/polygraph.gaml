/***
* Name: polygraph
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model polygraph

/* Insert your model definition here */

global {
	//file locations go here
	file catchment_shape <- file("../../../data/gis/catchment_shape.shp");
	
	//objects definition
	graph<geometry, geometry> catchment_network <- graph<geometry, geometry>([]);
	
	//constants etc
	geometry shape <- envelope(catchment_shape);
	
	init {
		map temp_downstream;
		loop cat over: catchment_shape {
			create catchment from: [cat] {
				temp_downstream[self] <- int(cat get "DOWNSTREAM") - 1;
			}
		}
		
		ask catchment {
			int catchment_index <- int(temp_downstream[self]);
			if catchment_index >= 0 {
				downstream <- catchment[catchment_index];
				ask downstream {
					upstream <- upstream + myself;
				}
				catchment_network <- catchment_network add_edge (self.location::downstream.location);
			}
			
		}
		
		ask catchment where (each.upstream = []) {
			catchment_type <- "head";
		}
		ask catchment where (each.downstream = nil) {
			catchment_type <- "out";
		}
	}
}

species catchment {
	catchment downstream;
	list<catchment> upstream;
	
	string catchment_type <- "intermediary";
	
	float in_flow;
	float out_flow;
	float storage;
	float constant;
		
	action flow (catchment target) {
		if target.catchment_type = "out" {
			ask upstream {
				do flow(self);
			}
			out_flow <- (storage/constant)^(-1/0.23);
			storage <- storage + (in_flow - out_flow);
			in_flow <- 0.0;
		}
		else if target.catchment_type = "head" {
			out_flow <- (storage/constant)^(-1/0.23);
			storage <- storage - out_flow;
			ask downstream {
				self.in_flow <- myself.out_flow;
			}
		}
		else {
			out_flow <- (storage/constant)^(-1/0.23);
			storage <- storage + (in_flow - out_flow);
			in_flow <- 0.0;
			ask downstream {
				self.in_flow <- myself.out_flow;
			}
		}
	}
	
	reflex when: catchment_type = "out" {
		do flow(self);
	}
	
	aspect default {
		draw shape color: #blue border: #black width: 3;
	}
}

species channel {
	
}

experiment Visualise type: gui {
	output {
		display geo type: opengl {
			species catchment;
			graphics "edges" position: {0, 0, 0.03} {
				loop edge over: catchment_network.edges {
					draw edge color: #yellow width: 5;
				}
			}
		}
	}
}