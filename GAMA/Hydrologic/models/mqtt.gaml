/***
* Name: mqtt
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model mqtt

/* Insert your model definition here */

global {
	
	
	init {
		create grabber {
			do connect to: "grus.its.uow.edu.au" protocol: "MQTT" port: 1883 with_name: "GAMA_SIM";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-19/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-20/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-21/up";
			do join_group with_name: "smart-stormwater-water-level/devices/wl-22/up";
		}
	}
}

species grabber skills: [network] {
	reflex fetch when: has_more_message() {
		message mess <- fetch_message();
		write name + " fetched: " + mess.contents;
	}
}

experiment Test type: gui {
	output {
		display main {
			species grabber;
		}
	}
}