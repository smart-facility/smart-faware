model playground

global {
	file rain_data <- file("../../../data/rain/gauges.csv");
	file catchments <- file("../../../data/gis/catchment_shape.shp");
	
	geometry shape <- envelope(catchments);
	
	init {
		matrix raintrix <- matrix(rain_data);
		//list precipitation <- raintrix row_at 0;
		//precipitation >>- precipitation select (!is_number(replace_regex(string(each), "[-:]", "")));
		//write raintrix index_of "568317";
		/*
		loop timestep over: precipitation {
			//write raintrix at (raintrix index_of timestep + {0, 4});
		}
		* */
		/*
		create rain {
			id <- 568317;
			index <- raintrix index_of string(id) - {1, 0};
			lat <- float(raintrix at (raintrix index_of "latitude" + index));
			lon <- float(raintrix at (raintrix index_of "longitude" + index));
			write lat;
			write lon;
			location <- point({lon, lat});
		}
		* */
	}
}

species rain {
	int id;
	point index;
	float lat;
	float lon;
	
	aspect default {
		draw circle(50) at: location;
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species rain;
		}
	}
}