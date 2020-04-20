model test

global {
	
	init {
		map yes <- [1::"a",2::"c",3::"a",5::"b",4::"a"];
		write yes.keys;
		write yes.values;
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			
		}
	}
}