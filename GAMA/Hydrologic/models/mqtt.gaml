/***
* Name: mqtt
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model mqtt

/* Insert your model definition here */

global {
	file catchment_shape <- file("../../../data/gis/catchment_shape.shp");
	file sensor_shape <- file("../../../data/gis/Sensors/sensor_voronoi.shp");
	geometry shape <- envelope(catchment_shape);
	
	
	init {
		create sense_network {
			do connect to: "grus.its.uow.edu.au" protocol: "MQTT" port: 1883 with_name: "GAMA_SIM";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-19/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-20/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-21/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-22/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-23/up";
			
			create sensor from: sensor_shape {
				id <- int(self get "id");
			}
		}
	}
}

species sense_network skills: [network] {
	string grab_tag_string (string mess, string tag) {
		list<string> list_mess <- list(mess);
		int index <- (list_mess last_index_of tag) + 3;
		int counter;
		list<string> collector;
		loop while: counter < 2 {
			if list_mess[index] = "\""{
				counter <- counter + 1;
			}
			else {
				collector << list_mess[index];
			}
			index <- index + 1;
		}
		string result <- "";
		loop sub over: collector {
			result <- result + sub;
		}
		return result;
	}
	
	float grab_tag_num (string mess, string tag) {
		list<string> list_mess <- list(mess);
		int index <- list_mess last_index_of tag + 3;
		int counter;
		list<string> collector;
		loop while: counter < 1 {
			if list_mess[index] = "\"" or list_mess[index] = ","{
				counter <- counter + 1;
			}
			else {
				collector << list_mess[index];
			}
			index <- index + 1;
		}
		string result <- "";
		loop sub over: collector {
			result <- result + sub;
		}
		return float(result);
	}
	
	
	reflex update when: has_more_message() {
		message mess <- fetch_message();	
		string dev_name <- grab_tag_string(mess.contents, "dev_id");
		float distance_received <- grab_tag_num(mess.contents, "distance");
		write "recieved: "+ dev_name + " distance: "+distance_received;
		int ID <- int(replace_regex(dev_name, "[^1234567890]", ""));
		
		ask sensor where (each.id = ID) {
			distance <- distance_received;
		}		
	}
	

	species sensor {
		int id;
		float distance;
	}
	
	aspect default {
		ask sensor {
			draw shape border: #black color: #green depth: distance/100;
			//draw circle(100) at: self.location border: #black color: #blue;
		}
	}
}

experiment Test type: gui {
	output {
		display main type: opengl{
			graphics "catchment" {
				loop cat over: catchment_shape {
					draw cat border: #black;
				}
			}
			
			species sense_network position: {0, 0, 0.1} transparency: 0.5;			
		}
	}
}