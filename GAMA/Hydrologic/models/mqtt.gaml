/***
* Name: mqtt
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model mqtt

/* Insert your model definition here */

global {
	string messo <- "{\"app_id\":\"smart-stormwater-water-level\",\"dev_id\":\"wl-20\",\"hardware_serial\":\"A81758FFFE045AB1\",\"port\":5,\"counter\":12269,\"payload_raw\":\"AQE6AjUHDisOC8gUAA+OWg==\",\"payload_fields\":{\"distance\":3016,\"humidity\":53,\"pressure\":1019.482,\"temperature\":31.4,\"vdd\":3627},\"metadata\":{\"time\":\"2020-02-28T01:44:59.449293167Z\",\"frequency\":923.2,\"modulation\":\"LORA\",\"data_rate\":\"SF7BW125\",\"airtime\":66816000,\"coding_rate\":\"4/5\",\"gateways\":[{\"gtw_id\":\"eui-00800000a0000b9b\",\"timestamp\":2724810891,\"time\":\"\",\"channel\":0,\"rssi\":-102,\"snr\":-2.8,\"rf_chain\":0,\"latitude\":-34.36688,\"longitude\":150.87569,\"altitude\":9,\"location_source\":\"registry\"}],\"latitude\":-34.39678,\"longitude\":150.9039,\"altitude\":3,\"location_source\":\"registry\"}}";
	
	string grab_tag_string (string mess, string tag) {
		list<string> list_mess <- list(mess);
		int index <- list_mess index_of tag + 3;
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
		int index <- list_mess index_of tag + 3;
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
	
	init {
		create grabber {
			do connect to: "grus.its.uow.edu.au" protocol: "MQTT" port: 1883 with_name: "GAMA_SIM";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-19/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-20/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-21/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-22/up";
		}
		string target <- "latitude";
		write grab_tag_num(messo, target);
	}
}

species grabber skills: [network] {
	reflex fetch when: has_more_message() {
		//write string(mailbox[length(mailbox)-1].contents) index_of "id";
		//message mess <- fetch_message();
		//write name + " fetched: " + mess.contents;
	}
}

experiment Test type: gui {
	output {
		display main {
			species grabber;
		}
	}
}