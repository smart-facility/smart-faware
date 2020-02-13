/***
* Name: Discrete
* Author: nhutchis
* Description: 
* Tags: discrete
***/

model Discrete

/* Insert your model definition here */

global {
	file catchments_shape <- file("../../../data/gis/catchment_shape.shp");
	file impervious_shape <- file("../../../data/gis/impervious_shape.shp");
	file elevation_tif <- file("../../../data/gis/elevation_grid.tif");
	file rain_tif <-file("../../../data/gis/rain_grid.tif");
	file rain_csv <- file("../../../data/rain/gong_csv.csv");
	
	topology rain_topo;
	
	float max_rain;
	
	geometry shape <- envelope(rain_tif); //could be dem_grid or rain_grid depending on what Anton says about resolution etc
		
	int end_precipitation; //after this step kills all rain cells to prevent indexing error
	
	float step <- 10#mn/74; //step sized determined from netCDF file, files last 10 minutes with 74 steps
	float resolution <- 10#m; //update to grab from the selected tif
	
	float infil_constant <- 5#mm; //better name, double check for certainty
	float infil_proportionate <- 0.1;
	float LAG_C <- 1.61;
	float LAG_IMPERV <- 0.1;
	float LAG_STREAM <- 1.0;
			
	init{
			rain_topo <- topology(matrix(rain_tif));
			loop cat over: catchments_shape {
				create catchment from: [cat];
			}
			
			ask land_cell {
				ask catchment overlapping location {
					myself.catchment_connected <- myself.catchment_connected + self;
					num_cells <- num_cells + 1;
				}
			if catchment_connected = [] { do die; }
		}
			
			geometry impervious_area <- geometry(impervious_shape);
			ask land_cell overlapping impervious_area {
				impervious <- true;
			}
			ask land_cell {
				ask rain_cell overlapping location {
					land_connected <- land_connected + myself;
				}
			}
			/*
			int i <- 0;
			loop cloud over: rain_cell {
				create land_block number: 1;
				ask cloud.land_connected {
					land_block[i].shape <- land_block[i].shape + self.shape;
				}
				i <- i + 1;
			}
			*/
			//ask catchment where (each overlaps rain_cell[30]) { do die; }
			
			/*ask rain_cell {
				ask catchment where (each overlaps self = true) {
					write("new thing");
					geometry new_shape;
					ask myself.land_connected where (self overlaps each = true) {
						new_shape <- new_shape + self.shape;
					}
					create land_block {
						shape <- new_shape;
					}
					
				}
			}*/
			ask rain_cell {
				ask catchment where (each overlaps self) {
					list<land_cell> temp_linked;
					int temp_pervious <- 0;
					int temp_impervious <- 0;
					
					ask land_cell where (each overlaps self and each overlaps myself) {
						temp_linked <- temp_linked + self;
						if self.impervious {
							temp_impervious <- temp_impervious + 1;
						}
						else {
							temp_pervious <- temp_pervious + 1;
						}
					}
					create land_block {
						linked_cells <- temp_linked;
						num_pervious <- temp_pervious;
						num_impervious <- temp_impervious;
					}
				}
			}
		}
		
}

species catchment {
	int num_cells <- 0;
	aspect default {
		draw shape border: #black width: 3;
	}
}

species land_block {
	list<land_cell> linked_cells;
	float infil_storage <- 0.0 max: infil_constant;
	int num_pervious;
	int num_impervious;
	
	reflex rand_colour {
		rgb temp_colour <- rgb(rnd(255), rnd(255), rnd(255));
		ask linked_cells {
			colour <- temp_colour;
		}
	}
}

grid land_cell file: elevation_tif {
	bool impervious <- false;
	rgb colour;
	list<catchment> catchment_connected;
	aspect default {
		draw shape color: colour;
	}
}

grid rain_cell file: rain_tif {
	list<land_cell> land_connected;
}



//rain cells are initialised from geotif file to give location etc
experiment Visualise type: gui {
	output {
		display disp type: opengl {
			species catchment;
			//species land_cell position: {0, 0, 0.25};
			species land_block position: {0, 0, 0.25};
			species rain_cell position: {0, 0, 0.5};
		}
	}
}