model jsonmodel

import "./components/visualisation.gaml"

global {	
	file experiments <- folder('../../../data/experiments');
	file parameters <- json_file(experiments.path+'/julyaug2020.json');
	file db_param <- json_file(experiments.path+'/'+map(parameters['data'])['db']);
	
	date start <- date(map(parameters['run'])['start']);
	date starting_date <- start - 20#mn;
	date end <- date(map(parameters['run'])['end']);
	date stopping_date <- end + 20#mn;
	float step <- float(map(parameters['run'])['step']);
	
	float lag_param <- float(map(parameters['flow'])['lag_param']);
	float stream_const <- float(map(parameters['flow'])['stream_const']);
	
    geometry shape <- map(parameters['data'])['geom'] = 'db' ? envelope(db_param.contents): envelope(file(map(parameters['data'])['geom']));
	
	init {
		create cloud;
		create catchment;
	}
	
	reflex stop when: (current_date > stopping_date) {
		do pause;
	}
}

species cloud skills: [SQLSKILL] {
	
	init {
		if map(parameters["data"])["rain"] = "bom" {
			list c <- select(params:db_param.contents, select:'SELECT st_asbinary(st_transform(geom, 28356)) AS geom, round(val::decimal, 2) AS val, stamp::text 
FROM rainfall_raster, st_dumpaspolygons(st_clip(rast, (SELECT st_expand(st_envelope(st_collect(geom)), 0.01) FROM catchment))) WHERE val > 0 AND stamp BETWEEN \''+start+'\' AND \''+end+'\'');
			create subcloud from: c with: [shape::'geom', time::'stamp', payload::'val'];
		} else if map(parameters["data"])["rain"] = "mhl" {
			list gauges <- map(parameters["data"])["gauges"];
			int len <- length(gauges);
			int count <- 1;
			string str <- '(';
			loop gauge over: gauges {
				if count >= len {
					str <- str + gauge + ')';
					break;
				}
				str <- str + gauge + ',';
				count <- count + 1;
			}
			list c <- select(params:db_param.contents, select:'SELECT val, stamp::text, st_asbinary(st_transform(geom, 28356)) AS geom FROM rainfall RIGHT JOIN (SELECT (dump.geom).geom, id FROM (SELECT st_dump(st_voronoipolygons(st_collect(geom))) AS geom
FROM information WHERE id IN '+str+') AS dump
CROSS JOIN
information WHERE st_intersects(information.geom, (dump.geom).geom) AND information.id IN '+str+') AS polys using(id)
WHERE val > 0 AND stamp BETWEEN \''+start+'\' AND \''+end+'\'');
			create subcloud from: c with: [shape::'geom', time::'stamp', payload::'val'];
		}
		
	}
	species subcloud parallel: true {
     	date time;
     	float payload;
     	
     	reflex when: time = current_date {
     		//talk to the subcatchments underneath the particular sub cloud
     		ask catchment[0].sub_catch where (each overlaps self) {
     			//send a volume equal to the size of intersection with the subcloud multiplied by the payload height
     			float send <- myself.payload#mm*intersection(self.shape, myself.shape).area;
     			rain_buffer <- rain_buffer + send;
     			rain_in <- rain_in + send;
     		}
     	}
     }
     
     aspect default {
     	ask subcloud where (each.time = current_date) {
     		//visualisation based on the BOM colour scale
 			rgb precip_colour <- world.colourise(payload, step);
 			draw shape color: precip_colour;
     	}
     }
}

species catchment skills: [SQLSKILL] {
	sub_catch outlet;
	
	reflex flow {
		ask outlet {
			do flow;
		}
	}
	
	init {
		//grab geometries for catchment and set up individual sub catchment agents with links to their respective upstream and downstream sub catchments
		list c <- select(params: db_param.contents, select:'SELECT st_asbinary(st_transform(geom, 28356)) AS geom, id, downstream FROM catchment ORDER BY id');
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
		float constant <- lag_param*((shape.area/#km^2)^0.57)#h;//*0.25;//0.5 constant added to decrease lag
		
		//geometry shape_3d;
		
		float rain_in;
				
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
				temp_out <- step*(storage/constant*stream_const)^(1/0.77);
				out_flow <- out_flow + temp_out;
				// temp_out <- storage;
				// out_flow <- out_flow + temp_out;
			}
			else {
				temp_out <- 0.0;
			}
			storage <- storage - temp_out;
			do drain_buffer;
			in_flow <- 0.0;
			//write out_flow/step;
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
			float level <- (storage+rain_buffer)*1000/(shape.area);
			draw shape at: location + {0, 0, 1} color: rgb(0,0,255, sqrt(level)/20) depth: level*10;
		}
	}
}

experiment run {
	output {
		display main type: opengl {
			species catchment;
			species cloud position: {0, 0, 0.5} transparency: 0.65;
		}
	}	
}

experiment upload skills: [SQLSKILL] {
	int experiment_index;
	map<int, string> upload_strings;
	init {
		//date(machine_time/1000)-(date(0)-date('19700101'))+11#h
		//string experiment_date <- string(current_date);
		do insert(params: db_param.contents, into: 'experiment_info', 
			columns: ['name', 'runtime', 'data', 'lag_param', 'stream_const', 'step', 'starttime', 'endtime'], 
			values: [parameters['name'], "current_timestamp", map(parameters["data"])["rain"], lag_param, stream_const, step, "'"+string(start)+"'::timestamp", "'"+string(end)+"'::timestamp"]
		);
		list get_index <- select(params: db_param.contents, select: 'SELECT index, name, runtime FROM experiment_info ORDER BY runtime DESC LIMIT 3');
		experiment_index <- int(list(list(get_index[2])[0])[0]);
		write 'experiment: ' + experiment_index;
		ask catchment[0].sub_catch {
			int catch_index <- catchment[0].sub_catch index_of self;
			myself.upload_strings[catch_index] <- '';
		}
	}
	
	reflex write {
		string timestep <- "'"+string(current_date)+"'::timestamp";
		ask catchment[0].sub_catch {
			int catch_index <- catchment[0].sub_catch index_of self;
			ask myself {
				upload_strings[catch_index] <- upload_strings[catch_index] + 'INSERT INTO experiment_data 
			(index, timestep, catchment, rain_in, rain_buffer, storage, flow) VALUES 
			('+experiment_index+','+timestep+','+catch_index+','+myself.rain_in/myself.shape.area+','+myself.rain_buffer+','+myself.storage+','+myself.out_flow/step+');';
			}
			rain_in <- 0.0;
		}
	}
	
	reflex uploader when: current_date > stopping_date {
		ask catchment[0].sub_catch {
			int catch_index <- catchment[0].sub_catch index_of self;
			ask myself {
				write 'uploading: ' + catch_index;
				do executeUpdate(params: db_param.contents, updateComm: upload_strings[catch_index]);
				upload_strings[catch_index] <- '';
				write 'uploaded';
			}
		}
	}
}