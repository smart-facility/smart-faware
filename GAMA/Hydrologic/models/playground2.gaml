model playground2

global {
	csv_file level_data <- csv_file("../../../data/rain/water_levels_formatted.csv");
	file sensor_shape <- file("../../../data/gis/Sensors/sensors.shp");
	file catchment_shape <- shape_file("../../../data/gis/3dshape.shp", true);
	
	geometry shape <- envelope(catchment_shape);
	
	date starting_date <- date("20200201");
	
	init {
		matrix levels <- matrix(level_data);
		list global_steps <- (levels row_at 0) select (is_number(replace_regex(string(each), "[^1234567890]", "")));
		
		create catchment from: catchment_shape;
		create level_sensor from: sensor_shape {
			point index <- (levels index_of string(id)) - {1, 0};
			if index = {-1, 0} {do die;}
			
			loop steppy over: global_steps {
				data << levels at (levels index_of steppy + index);
			}
			timesteps <- global_steps;
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
}

species level_sensor {
	int id;
	float max_dist;
	
	list<date> timesteps;
	list data;
	
	float data_now;
	
	reflex update when: false and (timesteps != []) and (current_date >= timesteps[0]) {
		if data[0] != "" {
			data_now <- max_dist - float(data[0]);
		}
		timesteps[] >>- 0;
		data[] >>- 0;
		
	}
	
	reflex update_batch when: (timesteps != []) and (current_date >= timesteps[0]) {
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
	}
	
	init {
		id <- int(self get "id");
	}
	
	aspect default {
		draw circle(30) border: #black color: #blue depth: data_now/25;
	}
}

species catchment {
	int id <- int(self get "ID");
	
	
	init {
		
	}
	
	aspect default {
		draw shape color: #lightgreen border: #black depth: 20;
	}
}

experiment Visualise {
	output {
		display main type: opengl {
			species catchment;
			species level_sensor position: {0, 0, 1e-3};
		}
	}
}