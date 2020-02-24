/***
* Name: Discrete
* Author: nhutchis
* Description: 
* Tags: discrete
***/

model Discrete

/* Insert your model definition here */

global {
	file catchment_shape <- file("../../../data/gis/catchment_shape.shp");
	file impervious_shape <- file("../../../data/gis/impervious_shape.shp");
	file elevation_tif <- file("../../../data/gis/elevation_grid.tif");
	file rain_shape <- file("../../../data/gis/gauge_voronoi.shp");
	file rain_csv <- file("../../../data/rain/1998.csv");
		
	geometry shape <- envelope(rain_shape); //could be dem_grid or rain_grid depending on what Anton says about resolution etc
		
	graph<geometry, geometry> catchment_network <- graph<geometry, geometry>([]);
		
	int end_precipitation; //after this step kills all rain cells to prevent indexing error
	
	float step <- 5#mn; //step sized determined from netCDF file, files last 10 minutes with 74 steps
	float resolution <- 10#m; //update to grab from the selected tif
	
	float infil_constant <- 5#mm; //better name, double check for certainty
	float infil_proportionate <- 0.1;
	float LAG_C <- 1.61;
	float LAG_IMPERV <- 0.1;
	float LAG_STREAM <- 1.0;
			
	init{
		//create low level catchments from shape file, these catchments are used to perform flow calculations and transmit water
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
				catchment_network <- catchment_network add_edge (self.location::downstream.location);
				ask downstream {
					upstream <- upstream + myself;
				}
			}			
		}
		
		ask catchment where (each.upstream = []) {
			catchment_type <- "head";
		}
		ask catchment where (each.downstream = nil) {
			catchment_type <- "out";
		}
		
		matrix rain <- matrix(rain_csv);
		end_precipitation <- rain.columns - 6;
		
		loop gauge over: rain_shape {
			create rain_poly from: [gauge] {
				id <- int(gauge get "id");
				loop row_num from: 0 to: rain.rows-1 {
					if self.id = int(rain[2, row_num]) {
						loop col_num from: 3 to: rain.columns-4 {
							precip_list <- precip_list + float(rain[col_num, row_num])*(step/#h)#mm;
						}
					}
				}
			}
		}
			
		//initialise land cells from elevation geotif, all cells which are not connected to a catchment are useless and hence removed
		ask land_cell {
			ask catchment overlapping location {
				myself.catchment_connected <- myself.catchment_connected + self;
				num_cells <- num_cells + 1;
			}
			if catchment_connected = [] { do die; }
		}
		//land cells over impervious areas are set to impervious, impervious areas have different runoff/lag properties and do not absorb water, giving it straight to runoff
		geometry impervious <- geometry(impervious_shape);
		ask land_cell overlapping impervious {
			impervious <- true;
			ask catchment_connected {
				num_imperv <- num_imperv + 1;
			}
		}
		
		//initialise each rain cell with its precipitation per step from bom data
		//the csv stores the data for the whole grid in a single column per time step
		
		
		//store list of connected land cells in each rain cell, this is used for the rain reflex
		ask land_cell {
			ask rain_poly overlapping location {
				self.land_connected <- self.land_connected + myself;
			}
		}
		
		ask catchment {
			constant <- 10*LAG_C*(resolution^2/1000^2*num_cells)^(0.57);
		}
		
	}
	//once the csv file is finished, kill all rain cells to avoid indexing errors in the precipitation list
	reflex stop_rain when: cycle = end_precipitation {
		ask rain_poly {
			do die;
		}
	}
		
}

//rain cells are initialised from geotif file to give location etc

species rain_poly {
	int id;
	list<float> precip_list;
	float precip_now update: precip_list at cycle;
	list<land_cell> land_connected;
	
	reflex raining when: precip_now > 0 {
		ask land_connected parallel: true {
			precip_received <- precip_received + myself.precip_now;
		}
	}
	aspect default {
		rgb precip_colour;
		float precip_now_mm_hr <- precip_now*(#h/step)/#mm;
		switch precip_now_mm_hr {
			match_between [0, 0.2] {precip_colour <- rgb(0,0,0,0);}
			match_between [0.2, 0.5] {precip_colour <- #white;}
			match_between [0.5, 1.5] {precip_colour <- #skyblue;}
			match_between [1.5, 2.5] {precip_colour <- #lightblue;}
			match_between [2.5, 4] {precip_colour <- #blue;}
			match_between [4, 6] {precip_colour <- #lightcyan;}
			match_between [6, 10] {precip_colour <- #cyan;}
			match_between [10, 15] {precip_colour <- #darkcyan;}
			match_between [15, 20] {precip_colour <- #yellow;}
			match_between [20, 35] {precip_colour <- #yellow/2 + #orange/2;}
			match_between [35, 50] {precip_colour <- #orange;}
			match_between [50, 80] {precip_colour <- #orangered;}
			match_between [80, 120] {precip_colour <- #red;}
			match_between [120, 200] {precip_colour <- #darkred;}
			match_between [200, 300] {precip_colour <- #maroon;}
			match_between [300, 10000] {precip_colour <- #black;}
		}
		draw shape color: precip_colour;
	}
}

grid land_cell file: elevation_tif {
	list<catchment> catchment_connected;
	float precip_received <- 0.0;
	float infil_storage <- 0.0 max: infil_constant;
	
	bool impervious <- false;
	/*
	 * try and factorise this section and use functions
	 */
	reflex storage when: !impervious and (infil_storage < infil_constant) and (precip_received > 0){
		float difference <- infil_storage + precip_received - infil_constant;
		if difference < 0 {
			infil_storage <- infil_storage + precip_received;
			precip_received <- 0.0;
		}
		else {
			infil_storage <- infil_constant;
			ask catchment_connected {
				storage <- storage + difference*(1-infil_proportionate)*resolution^2;
			}
			precip_received <- 0.0;
		}
	}
	
	reflex runoff_pervious when: (infil_storage = infil_constant) and (precip_received > 0) {
		ask catchment_connected {
			storage <- storage + myself.precip_received*(1-infil_proportionate)*resolution^2;
		}
		precip_received <- 0.0;
	}
	
	reflex runoff_impervious when: (impervious = true) and (precip_received > 0){
		ask catchment_connected {
			storage <- storage + myself.precip_received*resolution^2;
		}
		precip_received <- 0.0;
	}
	
	aspect default {
		rgb colour;
		if impervious { colour <- #black; }
		else {
			int storage_colour <- int(255*infil_storage/infil_constant);
			colour <- rgb(0, 255-storage_colour, storage_colour);
		}
		draw shape color: colour;
	}
}

species catchment {
	catchment downstream;
	list<catchment> upstream;
	
	string catchment_type <- "intermediary";
	
	int num_cells <- 0;
	int num_imperv <- 0;
	
	float in_flow;
	float out_flow;
	float storage;
	float constant;
		
	action flow (catchment target) {
		if target.catchment_type = "out" {
			ask upstream parallel: false {
				do flow(self);
			}
			
			if storage != 0 { out_flow <- step*50*(storage/constant#h)^(1/0.77); }
			else { out_flow <- 0.0; }
			
			write(string(target.catchment_type)+": "+string(out_flow));
			storage <- storage + (in_flow - out_flow);
			in_flow <- 0.0;
		}
		else if target.catchment_type = "head" {
			if storage != 0 { out_flow <- step*50*(storage/constant#h)^(1/0.77); }
			else { out_flow <- 0.0; }
			
			write(string(target.catchment_type)+": "+string(out_flow));
			storage <- storage - out_flow;
			ask downstream {
				self.in_flow <- myself.out_flow;
			}
		}
		else {
			ask upstream parallel: false {
				do flow(self);
			}
			if storage != 0 { out_flow <- step*50*(storage/constant#h)^(1/0.77); }
			else { out_flow <- 0.0; }
			
			write(string(target.catchment_type)+": "+string(out_flow));
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
		draw shape color: #blue depth: storage/500;
	}
}


experiment Visualise type: gui {
	parameter "Rain data CSV" var: rain_csv category: "Inputs";
	parameter "Elevation/Land Cell tif" var: elevation_tif category: "Inputs";
	output {
		display main type: opengl {	
			species catchment transparency: 0.6;
			
			//species land_cell position: {0, 0, 0.15} transparency: 0.4;
			/*
			graphics impervious position: {0, 0, 0.1} transparency: 0.2 {
				draw impervious_shape color: #darkgray;
			}
			*/
			
			/* graphics "edges" position: {0, 0, 0.2} {
				loop edge over: catchment_network.edges {
					draw edge color: #yellow width: 5;
				}
			} */
			
			species rain_poly position: {0, 0, 0.4} transparency: 0.6;
		}
		display charts refresh: every (1#cycle){
			chart "out catchment" type: series {
				data "total stored water" value: catchment[36].storage color: #green;
			}
		}
	}
}

experiment Log type: gui {
	
}