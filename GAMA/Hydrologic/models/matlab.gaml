/***
* Name: matlab
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model matlab


global {
	float ned <- 100.0;
	init {
		create mat {
			do eval("a = 5+"+ned+"; b=2");
			write value_of("a");
			write value_of("b");
		}
	}
}

species mat parent: agent_MATLAB {

}

experiment test type: gui {
	
}