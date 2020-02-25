model polygraph

global {
	/*
	 * Here listed are all the files responsible for initialising the model
	 */
	file rain_tif <- file("../../../data/gis/gauge_voronoi.shp");
	file catchment_shape <- file("../../../data/gis/catchment_shape.shp");
	file rain_csv <- file("../../../data/rain/1998.csv");
	
	/*
	 * a list of constants
	 */
	
	/*
	 * world parameters
	 */
	geometry shape <- envelope(catchment_shape);
	float step <- 5#mn;
	int end_rain;
	
	init {
		//create catchments
		create catchment from: catchment_shape {
			int down_index <- int(self get "DOWNSTREAM")-1;
			if down_index >= 0 {
				downstream <- catchment[down_index];
				ask downstream {
					upstream <- upstream + myself;
				}
			}
			
		}
		
		//create rain_polys
		matrix rain <- matrix(rain_csv);
		end_rain <- rain.columns-3;
		
		//loop used to allow independent use of geotifs and shape files
		loop poly over: rain_tif {
			create rain_poly from: [poly] {
				id <- int(self get "id");
				
				//conditional statement added to add id for tif files
				if id = 0 {
					id <- int(replace(name, "rain_poly", ""));
				}
				
				//grab column of matrix containing indices to check for the relevant row to grab rain from
				list indices;
				loop row from: 0 to: rain.rows-1 {
					indices <- indices + int(rain[2, row]);
				}
				int row <- indices index_of id;
				
				//create list of precipitation values and store as matrix in agent
				list<float> precip_list <- [];
				loop column from: 3 to: rain.columns-1 {
					precip_list <- precip_list + float(rain[column, row]);
				}
				precipitation <- matrix(precip_list);
				
				//create sub agents to connect to each catchment
				loop cat over: catchment where (each overlaps self) {
					create sub_rain from: [cat inter self] {
						//precipitation converted from mm/hr to mm @ current step, then multiplied by area to get volume
						precipitation_vol <- precipitation*(step/#h)#mm*self.shape.area;
						target <- cat;
					}
				}
			}
		}
		
		
		
	}
	
	reflex end_rain when: cycle = end_rain {
		ask rain_poly {
			do die;
		}
	}
}



species rain_poly {
	int id;
	matrix<float> precipitation;
	float precip_now update: precipitation[cycle];
	
	species sub_rain {
		matrix<float> precipitation_vol;
		float precip_now_vol update: precipitation_vol[cycle];
		catchment target;
		
		reflex rain {
			ask target {
				storage <- storage + myself.precip_now_vol;
			}
		}
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
	catchment downstream;
	list<catchment> upstream;
	
	float in_flow;
	float out_flow;
	float storage;
	
	float constant;
	
	aspect default {
		draw shape color: #blue depth: storage/500;
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species catchment transparency: 0.6;
			species rain_poly position: {0, 0, 0.4} transparency: 0.6;
		}
	}
}