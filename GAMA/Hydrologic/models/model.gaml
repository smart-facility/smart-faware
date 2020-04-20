model hydrologic

global {
	string mode <- "../../../data/model/";
	string expe <- "../../../data/experiments/1998-2012 MHL/";
	
	//Model Data
	file catchment_gis <- file(mode+"catchment_shape.shp");
	geometry shape <- envelope(catchment_gis);
	float step parameter: step <- 10#mn;
	 date starting_date <- date("20181004 23:00");
	
	//Experiment Data
	file cloud_gis <- file(expe+"mhl/mhl_voronoi.shp");
	file cloud_csv <- file(expe+"rain_in/1998.csv");
	
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
	
	
	init {
		create catchment from: catchment_gis;
		
		map cloud_data <- get_data(cloud_csv);
		
		loop spot over: cloud_gis {
			create cloud from: container<geometry>(spot) {
				int id <- int(self get "id");
				if id = 0 {
					id <- int(replace(self.name, "cloud", ""));
				}
				data <- cloud_data[id]["data"];
			}
		}
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

species catchment {
	
	aspect default {
		draw shape color: #lightgreen border: #black;
	}
}


experiment Visualise type: gui {
	output {
		display main type: opengl {
			species catchment;
			species cloud position: {0, 0, 0.4} transparency: 0.5;
		}
	}
}