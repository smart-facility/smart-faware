model polygraph

global {
	file rain_tif <- file("../../../data/gis/rain_grid.tif");
	file catchment_shape <- file("../../../data/gis/catchment_shape.shp");
	geometry shape <- envelope(catchment_shape);
	
	
	init {
		loop poly over: matrix(rain_tif) {
			create rain_poly from: [poly];
			write(poly);
		}
	}
}


species rain_poly {
	int id;
	list<float> precip_list;
	float precip_now update: precip_list at cycle;
	
	
	aspect default {
		draw shape color: #white border: #black width: 3;
	}
	aspect raining {
		rgb precip_colour;
		float precip_now_mm_hr <- precip_now*(#h/step)/#mm;
		switch precip_now_mm_hr {
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

experiment Visualise type: gui {
	output {
		display main type: opengl {
			species rain_poly;
		}
	}
}