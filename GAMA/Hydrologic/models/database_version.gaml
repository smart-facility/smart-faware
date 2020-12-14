model postgis

global {
	//setup to grab bounds of catchment from database
	map<string,string> BOUNDS <- [  
    //'srid'::'32648',
    'host'::'localhost',                                
    'dbtype'::'postgres',
    'database'::'floodaware',
    'port'::'5432',                             
    'user'::'floodaware',
    'passwd'::'1234',
    'select'::'SELECT ST_AsBinary(st_expand(st_envelope(st_collect(geom)), 0.01)) as geom FROM catchment'];
    geometry shape <- envelope(BOUNDS);
    
	date starting_date <- date('20200207');
	float step <- 5#mn;
	
	float LAG_PARAM <- 1.61;
	
	init {
		create cloud;
		create catchment;
	}
}


species cloud parent: AgentDB {
	map<string, string> POSTGRES <- [
     'host'::'localhost',
     'dbtype'::'postgres',
     'database'::'floodaware',
     'port'::'5432',
     'user'::'floodaware',
     'passwd'::'1234'];
     
     init {
     	do connect(params: POSTGRES);
     	//query databse to select raster area over catchment, and take polygons of groups of cells with equal precipitation within the particular timeframe
     	list c <- self.select('SELECT st_asbinary(geom) AS geom, round(val::decimal, 2) AS val, stamp::text 
FROM rainfall_raster, st_dumpaspolygons(st_clip(rast, (SELECT st_expand(st_envelope(st_collect(geom)), 0.01) FROM catchment))) WHERE val > 0 AND stamp BETWEEN \'20200207\' AND \'20200209 2359\'');
     	//subcloud is the individual polygon with a rain payload
     	create subcloud from: c with: [shape::'geom', time::'stamp', payload::'val'];
     }
     
     species subcloud {
     	date time;
     	float payload;
     	
     	reflex when: time = current_date {
     		//talk to the subcatchments underneath the particular sub cloud
     		ask catchment[0].sub_catch where (each overlaps self) {
     			//send a volume equal to the size of intersection with the subcloud multiplied by the payload height
     			float send <- myself.payload#mm*intersection(self.shape, myself.shape).area*1e10;
     			rain_buffer <- rain_buffer + send;
     			rain_in[current_date] <- rain_in[current_date] + send;
     		}
     	}
     }
     
     aspect default {
     	ask subcloud where (each.time = current_date) {
     		//visualisation based on the BOM colour scale
 			rgb precip_colour;
			switch (payload#h)/step {
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
}

species catchment parent: AgentDB {
	sub_catch outlet;
	
	map<string, string> POSTGRES <- [
     'host'::'localhost',
     'dbtype'::'postgres',
     'database'::'floodaware',
     'port'::'5432',
     'user'::'floodaware',
     'passwd'::'1234'];
	
	reflex flow {
		ask outlet {
			do flow;
		}
	}
	
	init {
		do connect(params: POSTGRES);
		//grab geometries for catchment and set up individual sub catchment agents with links to their respective upstream and downstream sub catchments
		list c <- self.select('SELECT st_asbinary(geom) AS geom, id, downstream, st_area(st_transform(geom, 28356)) AS area FROM catchment');
		create sub_catch from: c with: [shape::'geom', id::'id', downstream_int::'downstream'];
		ask sub_catch {
			downstream <- downstream_int > 0 ? sub_catch[downstream_int - 1] : nil;
		}
		ask sub_catch {
			upstream <- sub_catch where (each.downstream = self);
		}
		outlet <- one_of(sub_catch where (each.downstream = nil));
	}
	
	species sub_catch {
		int id;
		int downstream_int;
		
		sub_catch downstream;
		list<sub_catch> upstream;
		//the constant part of the wbnm equations is calculated beforehand to save on execution time
		float constant <- LAG_PARAM*((shape.area*1e10/#km^2)^0.57)#h;//*0.25;//0.5 constant added to decrease lag
		
		//geometry shape_3d;
		
		map<date, float> rain_in;
				
		float in_flow <- 0.0;
		float out_flow <- 0.0;
		float storage <- 0.0;
		float rain_buffer <- 0.0;
		
		action drain_buffer {
			if rain_buffer != 0 {
				float buffer_out <- step*(rain_buffer/constant)^(1/0.77);
				rain_buffer <- rain_buffer - buffer_out;
				out_flow <- out_flow + buffer_out;	
			}
		}
		
		//recursively call flow from upstream and send downstream
		action flow {
			out_flow <- 0.0;
			if upstream != [] {
				ask upstream {do flow;}
			}
			storage <- storage + in_flow;
			float temp_out;
			if storage != 0 {
				temp_out <- step*(storage/constant*0.6)^(1/0.77);
				out_flow <- out_flow + temp_out;
			}
			else {
				temp_out <- 0.0;
			}
			storage <- storage - temp_out;
			do drain_buffer;
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
			//draw geometry
			draw shape border: #black color: #lightgreen;
			
			//draw water level above geometry
			float level <- (storage+rain_buffer)*1000/(shape.area*1e10);
			draw shape at: location + {0, 0, 1e-5} color: rgb(0,0,255, sqrt(level)/20) depth: level*1e-4;
		}
	}
}

experiment main {
	output  {
		display main type: opengl {
			species catchment;
			species cloud position: {0, 0, 0.5} transparency: 0.65;
		}
	}
}

experiment write_output type: gui {
	output {
		display main type: opengl background: #black {
			species catchment;
			species cloud position: {0, 0, 0.5} transparency: 0.65;
		}
	}
	
	file expe <- folder('c:/users/nhutchis/documents/projects/smart-faware/data/experiments/rudy79');
	date stopping_date <- date('20200209_2359');
	
	string rain_file_out <- expe.path+"/output/rain.csv";
	string storage_file_out <- expe.path+"/output/storage.csv";
	string outflow_file_out <- expe.path+"/output/outflow.csv";
	init {
		save ["datetime"] + (catchment[0].sub_catch collect (each.name)) to: rain_file_out rewrite: true type: "csv" header: false;
		save ["datetime"] + (catchment[0].sub_catch collect (each.name)) to: storage_file_out rewrite: true type: "csv" header: false;
		save ["datetime"] + (catchment[0].sub_catch collect (each.name)) to: outflow_file_out rewrite: true type: "csv" header: false;
	}
	/*
	reflex write_rain when: (current_date <= stopping_date){
		list values;
		loop cat over: catchment[0].sub_catch {
			values <+ cat.rain_in[current_date] / cat.shape.area;
		}
		save [string(current_date)] + values  to: rain_file_out rewrite: false type: "csv";
	}
	*/
	reflex write_storage when: (current_date <= stopping_date){
		save [string(current_date)] + (catchment[0].sub_catch collect (each.storage)) to: storage_file_out rewrite: false type: "csv";
	}
	reflex write_outflow when: (current_date <= stopping_date){
		save [string(current_date)] + (catchment[0].sub_catch collect (each.out_flow/step)) to: outflow_file_out rewrite: false type: "csv";
	}
	reflex stop when: (current_date > stopping_date){
		loop date over: catchment[0].sub_catch[0].rain_in.keys {
			list values;
			loop cat over: catchment[0].sub_catch {
				values <+ cat.rain_in[date] / (cat.shape.area*1e10);
			}
			/*write values;*/
			save [string(date)] + values  to: rain_file_out rewrite: false type: "csv";
		}
		ask simulation {
			do pause;
		}
	}
}