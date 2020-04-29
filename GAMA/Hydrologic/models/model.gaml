model hydrologic

global {
	file mode <- folder("../../../data/model/");
	file expe <- folder("../../../data/experiments/2020_Feb8/") parameter: "Experiment Folder";
	
	//Model Data
	file catchment_gis <- file(mode.path+"/catchment_shape.shp");
	file catchment_3d <- shape_file(mode.path+"/3dshape.shp", true);
	geometry shape <- envelope(catchment_gis);
	
	
	//Experiment Data
	//Determine the type of file used in the rain_in folder, could be tif, or shp
	string cloud_gis_name <- one_of(list(folder(expe.path+"/rain_in").contents) select ((string(each) contains ".shp") or (string(each) contains ".tif")));
	file cloud_gis <- file(expe.path+"/rain_in/"+cloud_gis_name);
	file cloud_csv <- file(expe.path+"/rain_in/rain.csv");
	
	file sensor_gis <- file(expe.path+"/validation/coords.shp");
	file sensor_csv <- file(expe.path+"/validation/level.csv");
	
	//Experiment Params
	float step parameter: step <- 5#mn;
	date starting_date <- date(matrix(cloud_csv.contents) column_at 0 at ((matrix(cloud_csv.contents) column_at 0 index_of "###START_DATA###") + 1)) - 30#mn;
	date stopping_date <- date(reverse(matrix(cloud_csv.contents) column_at 0)[0]) + 30#mn;
	
	//Constants etc
	float LAG_PARAM <- 1.61;
	
		
	init {
		create catchment {
	 		create sub_catch from: catchment_gis {
	 			shape_3d <- one_of(catchment_3d where (each get "ID" = self get "ID"));
	 		}
	 		outlet <- one_of(sub_catch where (each.downstream = nil));
	 		ask sub_catch {upstream <- sub_catch where (each.downstream = self);}
	 	}
		
		//Initialise Clouds
		map cloud_data <- get_data(cloud_csv);
		
		loop spot over: cloud_gis {
			create cloud from: container<geometry>(spot) {
				int id <- int(self get "id");
				if id = 0 {
					id <- int(replace(self.name, "cloud", ""));
				}
				if id in cloud_data.keys {
					data <- cloud_data[id]["data"];
				}
				else {
					do die;
				}
				
				loop cat over: catchment[0].sub_catch where (each overlaps self) {
	 				create sub_cloud from: [cat inter self.shape] {
	 					target <- cat;
	 				}
	 			}
			}
		}
		
		//Initialise Sensors
		map sensor_data <- get_data(sensor_csv);
		create sensor from: sensor_gis {
			if id in sensor_data.keys {
				data <- sensor_data[id]["data"];
			}
			else {
				do die;
			}
			
		}
	}
	
	//CSV Data importer
	map<int, map> get_data (file csv_in) {
		map<int, map> output;
		matrix data <- matrix(csv_in);
		list dates <- data column_at 0 select ((data index_of each).y > (data index_of "###START_DATA###").y);
		list ids <- data row_at 0 select (each != "id");
		loop id over: ids {
			int idx <- data row_at 0 index_of id;
			map<date, float> id_data;
			loop date_it over: dates {
				id_data[date_it] <- float(data at ((data index_of date_it) + {idx, 0, 0}));
			}
			output[int(id)] <- ["data"::id_data];
		}
		return output;
	}
}

species cloud {
	map<date, float> data;
	float precip_now;
	
	reflex update_precip {
		precip_now <- 0.0;
		list times <- data.keys where ((each >= current_date) and (each < current_date + step));
		loop timey over: times {
			precip_now <- precip_now + data[timey];
		}
	}
	
	species sub_cloud {
		sub_catch target;
		
		reflex rain {
			float send <- host.precip_now#mm*self.shape.area;
			ask target {
				storage <- storage + send;
				rain_in <- rain_in + send;
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

species sensor {
	int id;
	point outlet;
	
	rgb colour <- #red;
	date last_update <- starting_date;
	
	map<date, float> data;
	float data_now;
	
	reflex update when: (data.keys where ((each >= current_date) and (each < current_date + step))) != []{
		colour <- #blue;
		list levels;
		list times <- data.keys where ((each >= current_date) and (each < current_date + step));
		loop timey over: times {
			levels <+ data[timey];
		}
		data_now <- float(max(levels));
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
		draw circle(30) border: #black color: colour depth: data_now*10;
	}
}

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
		
		geometry shape_3d;
		
		float rain_in;
				
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

	aspect catch_3d {
		ask sub_catch {
			draw shape_3d border: #black color: #lightgreen;
			float level <- storage*1000/self.shape.area;
			draw shape_3d at: shape_3d.centroid + {0, 0, 10} color: rgb(0,0,255, sqrt(level)/20) depth: level;
		}
	}
	aspect debug {
		ask sub_catch {
			draw shape border: #black color: #lightgreen;
			float level <- storage*1000/self.shape.area;
			draw shape at: location + {0, 0, 1e2} color: rgb(0,0,255, sqrt(storage/1000)/20) depth: storage/1000;
		}
	}
}


experiment Visualise type: gui {
	output {
		display main type: opengl {
			species catchment aspect: catch_3d;
			species sensor position: {0, 0, 0.1};
			species cloud position: {0, 0, 0.4} transparency: 0.5;
		}
	}
}

experiment debug type: gui {
	file outlets <- file(mode.path+"/nodes_points_catchment.shp");
	output {
		display main type: opengl background: #black {
			species catchment aspect: debug;
			graphics "connections" position: {0, 0, 0.025} {
				loop cat over: catchment[0].sub_catch {
					geometry down_cat <- cat.downstream != nil? cat.downstream.shape:{0,0,0};
					geometry double_down_cat <- cat.downstream.downstream != nil? cat.downstream.downstream.shape:{0,0,0};
					point cat_outlet <- container<point>(outlets) where (each overlaps cat) closest_to(down_cat);
					point down_outlet <- container<point>(outlets) where (each overlaps cat.downstream) closest_to(double_down_cat);
					draw line(cat_outlet != nil? cat_outlet: cat.location, down_outlet != nil? down_outlet: cat.downstream.location) color: #blue width: 2;
					draw sphere(50) color: #darkblue at: cat_outlet != nil? cat_outlet: cat.location;
					draw replace(cat.name, "sub_", "") color: #red font: font("Helvetica", 32, #plain) at: cat.location;
				}
			}
			species sensor position: {0, 0, 0.1};
			species cloud position: {0, 0, 0.4} transparency: 0.5;
			
		}
	}
	reflex values {
		write catchment[0].sub_catch[36].in_flow;
	}
}

experiment write_output type: gui {
	output {
		display main type: opengl {
			species catchment aspect: catch_3d;
			species sensor position: {0, 0, 0.1};
			species cloud position: {0, 0, 0.4} transparency: 0.5;
		}
	}
	string rain_file_out <- expe.path+"/output/cum_rain.csv";
	string storage_file_out <- expe.path+"/output/storage.csv";
	string outflow_file_out <- expe.path+"/output/outflow.csv";
	init {
		save ["datetime"] + (catchment[0].sub_catch collect (each.name)) to: rain_file_out rewrite: true type: "csv" header: false;
		save ["datetime"] + (catchment[0].sub_catch collect (each.name)) to: storage_file_out rewrite: true type: "csv" header: false;
		save ["datetime"] + (catchment[0].sub_catch collect (each.name)) to: outflow_file_out rewrite: true type: "csv" header: false;
	}
	
	reflex write_rain when: (current_date <= stopping_date){
		list values;
		loop cat over: catchment[0].sub_catch {
			values <+ cat.rain_in / cat.shape.area;
		}
		save [string(current_date)] + values  to: rain_file_out rewrite: false type: "csv";
	}
	reflex write_storage when: (current_date <= stopping_date){
		save [string(current_date)] + (catchment[0].sub_catch collect (each.storage)) to: storage_file_out rewrite: false type: "csv";
	}
	reflex write_outflow when: (current_date <= stopping_date){
		save [string(current_date)] + (catchment[0].sub_catch collect (each.out_flow/step)) to: outflow_file_out rewrite: false type: "csv";
	}
	reflex stop when: (current_date > stopping_date){
		ask simulation {
			do pause;
		}
	}
}

experiment maplabels type: gui {
	file outlets <- file(mode.path+"/nodes_points_catchment.shp");
	output {
		display catchment_labels type: opengl {
			species catchment;
			graphics "names" {
				loop cat over: catchment[0].sub_catch {
					draw replace(cat.name, "sub_catch", "") font: font("Helvetica", 25, #plain) at: one_of(container<point>(outlets) where (each overlaps cat));
				}
			}
		}
	}
}