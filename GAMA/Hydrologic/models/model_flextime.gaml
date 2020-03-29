model modelflextime

global {
	/*First all GIS files and CSV data are imported to initialise catchments,
	 *  clouds, water levels, etc
	 */
	 file clouds_gis <- file("../../../data/gis/mhl/mhl_voronoi.shp");
	 file clouds_csv <- file("../../../data/rain/gauges.csv");
	 file catchments_gis <- file("../../../data/gis/catchment_shape.shp");
	 file sensors_gis <- file("../../../data/gis/Sensors/sensors.shp");
	 file sensors_csv <- file("../../../data/rain/water_levels_formatted.csv");
	 
	 /*Constants relating to flow of water from catchments, and any others etc */
	 float LAG_PARAM <- 1.61;
	 
	 /*World parameters */
	 geometry shape <- envelope(catchments_gis);
	 float step parameter: step <- 5#mn;
	 date starting_date <- date("20200201");
	 
	 init {
	 	create catchment {
	 		create sub_catch from: catchments_gis;
	 		outlet <- one_of(sub_catch where (each.downstream = nil));
	 		ask sub_catch {upstream <- sub_catch where (each.downstream = self);}
	 	}
	 	
	 	matrix clouds_precip <- matrix(clouds_csv);
	 	list clouds_timesteps <- (clouds_precip row_at 0) select (is_number(replace_regex(string(each), "[^1234567890]", "")));
	 	
	 	create cloud from: clouds_gis {
	 		precipitation <- host.data_from_csv(clouds_precip, int(self get "id"));
	 		timesteps <- clouds_timesteps;
	 		
	 		loop cat over: catchment[0].sub_catch where (each overlaps self) {
	 			create sub_cloud from: [cat inter self] {
	 				target <- cat;
	 			}
	 		}
	 	}
	 	
	 	matrix levels <- matrix(sensors_csv);
	 	list levels_timesteps <- (levels row_at 0) select (is_number(replace_regex(string(each), "[^1234567890]", "")));
	 	create level_sensor from: sensors_gis {
	 		point index <- levels index_of string(id) - levels index_of "id";
	 		if index = -(levels index_of "id") {do die;}
	 		data <- host.data_from_csv(levels, id);
	 		timesteps <- levels_timesteps;
	 	}
	 	ask level_sensor where (each.id = 2) {
			max_dist <- 3500.0;
		}
			
		ask level_sensor where (each.id = 19) {
			max_dist <- 2000.0;
		}
			
		ask level_sensor where (each.id = 21) {
			max_dist <- 4000.0;
		}
	 }
	  
	 list<float> data_from_csv (matrix input, int id) {
	 	list timesteps <- (input row_at 0) select (is_number(replace_regex(string(each), "[^1234567890]", "")));
	 	point index <- input index_of string(id) - input index_of "id";
	 	list<float> output;
	 	loop timestep over: timesteps {
	 		output << float(input at (input index_of timestep + index));
	 	}
	 	return output;
	 }
}

species cloud {
	
	list<date> timesteps;
	list<float> precipitation;
	float precip_now <- 0.0;
	
	reflex rain_batch when: (timesteps != []) and (timesteps[0] <= current_date) {
		list batch <- timesteps select (each <= current_date);
		precip_now <- 0.0;
		int index;
		list indices;
		
		loop steppy over: batch {
			index <- timesteps index_of steppy;
			precip_now <- precip_now + precipitation at index;
			indices << index;
		}
		timesteps[] >>- indices;
		precipitation[] >>- indices;
	}
	
	species sub_cloud {
		sub_catch target;
		
		reflex rain {
			float send <- host.precip_now#mm*shape.area;
			ask target {
				storage <- storage + send;
			}
		}
	}
	
	aspect default {
		rgb precip_colour;
		switch (precip_now#h)/step {
			match_between [0, 0.02] {precip_colour <- rgb(0,0,0,0);}
			match_between [0.02, 0.5] {precip_colour <- #white;}
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
/* catchment is a species to control all global aspects of the entire catchment,
 * with subspecies sub_catch controlling aspects local to each sub catchment.
 */
species catchment {
	sub_catch outlet;
	
	reflex flow {
		ask outlet {
			do flow;
		}
	}
	
	species sub_catch {
		sub_catch downstream <- is_number(string(self get "DOWNSTREAM")) ? sub_catch[int(self get "DOWNSTREAM")-1] : nil;
		list<sub_catch> upstream;
		float constant <- LAG_PARAM*((self.shape.area/#km^2)^0.57)#h;
		
		float in_flow <- 0.0;
		float out_flow <- 0.0;
		float storage <- 0.0;
		
		action flow {
			if upstream != [] {
				ask upstream {do flow;}
			}
			storage <- storage + in_flow;
			if storage != 0 {
				out_flow <- step*(storage/constant)^(1/0.77);
			}
			else {
				out_flow <- 0.0;
			}
			storage <- storage - out_flow;
			in_flow <- 0.0;
			if downstream != nil {
				ask downstream {
					self.in_flow <- self.in_flow + myself.out_flow;
				}
			}
		}
	}
	
	aspect default {
		ask sub_catch {
			draw shape border: #black color: #lightgreen;
			float level <- storage*1000/self.shape.area;
			draw shape at: location + {0, 0, 1e2} color: rgb(0,0,255, sqrt(level)/20) depth: level;
		}
	}
}

species level_sensor {
	int id;
	float max_dist;
	
	rgb colour <- #red;
	date last_update <- starting_date;
	
	list<date> timesteps;
	list data;
	
	float data_now;
	
	reflex update_batch when: (timesteps != []) and (current_date >= timesteps[0]) {
		colour <- #blue;
		list batch <- timesteps select (each <= current_date);
		list<int> indices;
		loop item over: batch {
			indices << timesteps index_of item;
		}
		
		if last(batch) != "" {
			data_now <- max_dist - float(data[last(indices)]);
		}
		timesteps[] >>- indices;
		data[] >>- indices;
		
		last_update <- current_date;
	}
	
	reflex data_old when: last_update + 1#day < current_date {
		colour <- #red;
		data_now <- 0.0;
	}
	
	init {
		id <- int(self get "id");
	}
	
	aspect default {
		draw circle(30) border: #black color: colour depth: data_now/25;
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species catchment;
			species level_sensor position: {0, 0, 0.1};
			species cloud position: {0, 0, 0.15} transparency: 0.5;
		}
	}
}

experiment Export type: gui {
	string output_file <- "../output/out_compare.csv";
	
	init {
		list columns;
		columns << "time";
		
		ask level_sensor {
			columns << "wl-"+string(id);
			ask catchment[0].sub_catch where (each overlaps self) {
				columns << "wl-"+string(myself.id)+"_catchment";
			}
		}
		save columns to: output_file rewrite: true type: "csv" header: false;
	}
	
	reflex save {
		list columns;
		columns << string(current_date);
		
		ask level_sensor {
			columns << data_now;
			ask catchment[0].sub_catch where (each overlaps self) {
				columns << storage;
			}
		}
		save columns to: output_file rewrite: false type: "csv" header: false;
	}
	
	output {
		display main type: opengl {
			species catchment;
			species level_sensor position: {0, 0, 0.1};
			species cloud position: {0, 0, 0.15} transparency: 0.5;
		}
	}
}