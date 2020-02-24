/***
* Name: playground2
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model playground2

/* Insert your model definition here */

global {
	file catchment_shape <- file("../../../data/gis/catchment_shape.shp");
	geometry shape <- envelope(catchment_shape);
	
	init {
		create catchment from: catchment_shape {
			int down_int <- int(self get "DOWNSTREAM") - 1;
			if down_int >= 0 {
				downstream <- catchment[down_int];
				ask downstream {
					upstream <- upstream + myself;
				}
			}
		}
	}
}

species catchment parent: graph_node edge_species: stream {
	catchment downstream;
	list<catchment> upstream;
	
	//graph my_graph;
	
	bool related_to (catchment other) {
		return true;
	}
	
	aspect default {
		draw shape color: #blue border: #black width: 3;
	}
}

species stream parent: base_edge {
	
	aspect default {
		draw shape color: #white width: 2;
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species catchment;
			species stream position: {0, 0, 0.1};
		}
	}
}