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

species catchment edge_species: stream {
	catchment downstream;
	list<catchment> upstream;
		
	aspect default {
		draw shape color: #blue;
	}
}

species stream parent: base_edge {
	
	aspect default {
		draw shape color: #black;
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