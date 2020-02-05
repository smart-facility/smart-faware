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
	file rain_csv <- file("../../../data/rain/test.csv");
	
	float max_rain;
	
	geometry shape <- envelope(rain_tif); //could be dem_grid or rain_grid depending on what Anton says about resolution etc
	
	
	bool parallel <- true; //check if this is necessary later
	
	int end_precipitation; //better name, just used to cut off precip calculations when there is no rain
	
	float step <- 10#mn/74;
	float resolution <- 10#m; //update to grab from the selected tif
	
	float infil_constant <- 5#mm; //better name, double check for certainty
	float infil_proportionate <- 0.1;
	float LAG_C <- 1.61;
	float LAG_IMPERV <- 0.1;
	float LAG_STREAM <- 1.0;
	
	//come up with some better names for these, check usage a bit more
	list<float> hydro;
	list<float> total_volume_global;
	float global_volume;
	
	
		
	init{
		//create catchments from shape file
		loop cat over: catchments_shape {
			create catchment from: [cat] {
				downstream <- int(cat get "DOWNSTREAM")-1;
				
			}
		}
			
		//initialise land cells from elevation geotif
		ask land_cell {
			ask catchment overlapping location {
				myself.catchment_connected <- myself.catchment_connected + self;
				num_cells <- num_cells + 1;
			}
			if catchment_connected = [] { do die; }
		}
		
		geometry impervious <- geometry(impervious_shape);
		ask land_cell overlapping impervious {
			impervious <- true;
			ask catchment_connected {
				num_imperv <- num_imperv + 1;
			}
		}
		
		//initialise each rain cell with its precipitation per step		
		matrix rain <- matrix(rain_csv);
		loop id from: 0 to: rain.rows-1 {
			ask rain_cell{
				if (string(id) = replace(name, "rain_cell", "")) {
					loop val from: 0 to: rain.columns - 4 {
						precip_list <- precip_list + float(rain[val+3, id])#mm;
					}
				}
				float local_max <- precip_list max_of each;
				if local_max > max_rain {
					max_rain <- local_max;
				}
			}
		}
		ask land_cell {
			ask rain_cell overlapping location {
				self.land_connected <- self.land_connected + myself;
			}
		}
		
	}
		
}
	
grid rain_cell file: rain_tif {
	list<float> precip_list;
	float precip_now update: precip_list at cycle;
	list<land_cell> land_connected;
	
	reflex raining when: precip_now > 0{
		ask land_connected parallel: true {
			precip_received <- precip_received + myself.precip_now;
		}
	}
	
	aspect default {
		int precip_colour <- 255-int(log(precip_now/max_rain*10+1)*255);
		draw shape color: rgb(precip_colour, precip_colour, 255);
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
				runoff_pervious <- runoff_pervious + difference*(1-infil_proportionate)*resolution^2;
			}
			precip_received <- 0.0;
		}
	}
	
	reflex runoff_pervious when: (infil_storage = infil_constant) and (precip_received > 0) {
		ask catchment_connected {
			runoff_pervious <- runoff_pervious + myself.precip_received*(1-infil_proportionate)*resolution^2;
		}
		precip_received <- 0.0;
	}
	
	reflex runoff_impervious when: (impervious = true) and (precip_received > 0){
		ask catchment_connected {
			runoff_impervious <- runoff_impervious + myself.precip_received*resolution^2;
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
	int downstream;
	int num_cells;
	int num_imperv;
	
	float runoff_pervious;
	float runoff_impervious;
	float runoff_channel;
		
	reflex store_perv when: (runoff_pervious != 0) {
		float lag_time <- time + LAG_C* (resolution^2/1000^2*(num_cells-num_imperv))^(0.57) * (runoff_pervious/step)^(-0.23) * 3600;
		create water {
			from <- myself;
			target <- myself.downstream;
			type <- "perv";
			lag <- lag_time;
			amount <- myself.runoff_pervious;
		}
		runoff_pervious <- 0.0;
	}
	
	reflex store_imperv when: (runoff_impervious != 0) {
		float lag_time <- time + LAG_C*LAG_IMPERV* (resolution^2/1000^2*num_imperv)^(0.25) * 3600;
		create water {
			from <- myself;
			target <- myself.downstream;
			type <- "imperv";
			lag <- lag_time;
			amount <- myself.runoff_impervious;
		}
		runoff_impervious <- 0.0;
	}
	
	reflex store_channel when: (runoff_channel != 0) {
		float lag_time <- time + LAG_C * LAG_STREAM * 0.6 * (resolution^2/1000^2*num_cells)^(0.57) * (runoff_channel/step)^(-0.23) * 3600;
		create water {
			from <- myself;
			target <- myself.downstream;
			type <- "channel";
			lag <- lag_time;
			amount <- myself.runoff_channel;
		}
		runoff_channel <- 0.0;
	}
	
	rgb colour <- #white;
	
	rgb update_colour {
		/*
		 * optimise colour selection, likely dependent on the quality of the water
		 * transition/lag functionality.
		 */
		float total_volume <- runoff_pervious + runoff_impervious + runoff_channel;
		int val_water <- int(255*(total_volume/(num_cells*resolution^2)*200));
		colour <- rgb([255-val_water, 255-val_water, 255]);
		return colour;
	}
	
	aspect default {
		colour <- update_colour();
		draw shape color: colour border: #black width: 2.0;
	}
}

species water {
	catchment from;
	int target;
	string type;
	float lag;
	float amount;
	reflex deposit when: lag < (time + step) {
		/*
		 * introduce code to create a smooth flow from catchment to catchment
		 * potentially by subtracting amounts every tick until amount empty
		 * have an extra set of variables just for display/record purposes
		 * which are updated smoothly
		switch type {
			match "perv" { from.runoff_pervious <- from.runoff_pervious - amount; }
			match "imperv" { from.runoff_impervious <- from.runoff_impervious - amount; }
			match "channel" { from.runoff_channel <- from.runoff_channel - amount; }
		}
		*/
		if target != -1 {
			catchment[target].runoff_channel <- catchment[target].runoff_channel + amount;
		}
		do die;
	}
}

experiment Visualise type: gui {
	parameter "Rain data CSV" var: rain_csv category: "Inputs";
	parameter "Elevation/Land Cell tif" var: elevation_tif category: "Inputs";
	output {
		display main type: opengl {	
			species catchment;
			species land_cell position: {0, 0, 0.15} transparency: 0.4;
			species rain_cell position: {0, 0, 0.4} transparency: 0.6;
		}
		
		display charts refresh: every(1#cycles) {
			chart "out catchment" type: series { 
				data "total volume" value: catchment[36].runoff_channel + catchment[36].runoff_pervious + catchment[36].runoff_impervious color: #green;
			}
		}
		
	}
}

experiment Log type: gui {
	
}