model playground

global {
	file rain_data <- file("../../../data/rain/gauges.csv");
	file catchments <- file("../../../data/gis/catchment_shape.shp");
	file rain_cells <- file("../../../data/gis/mhl/mhl_voronoi.shp");
	
	geometry shape <- envelope(rain_cells);
	
	float step <- 5#mn;
	
	date starting_date <- date("20200201");
	
	init {
		matrix raintrix <- matrix(rain_data);
		list global_steps <- raintrix row_at 0;
		global_steps >>- global_steps select (!is_number(replace_regex(string(each), "[^1234567890]", "")));
		
		list ids <- raintrix column_at 1;
		ids >>- "id";
		
		create catchment from: catchments;
		
		create rain from: rain_cells {
			id <- int(self get "id");
			point index <- raintrix index_of string(id) - {1, 0};
			lat <- float(raintrix at (raintrix index_of "latitude" + index));
			lon <- float(raintrix at (raintrix index_of "longitude" + index));
						
			loop timestep over: global_steps {
				precipitation << float(raintrix at (raintrix index_of timestep + index));
			}
			timesteps <- global_steps;
		}
	}
}

species rain {
	int id;
	
	float lat;
	float lon;
	
	list<date> timesteps;
	list<float> precipitation;
	float precip_now;
	
	reflex pause when: length(timesteps) = 2 {
		ask host {
			do pause;
		}
		
	}
	
	reflex do_rain when: timesteps[0] <= current_date {
		precip_now <- precipitation[0];
		timesteps[] >>- 0;
		precipitation[] >>- 0;
	}
	
	
	aspect default {
		rgb precip_colour;
		switch precip_now {
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

species catchment {
	
	aspect default {
		draw shape border: #black color: #blue;
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species rain;
			species catchment;
		}
	}
}