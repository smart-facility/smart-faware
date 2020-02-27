model playground

global {
	geometry shape <- square(1000);
	
	init {
		create voroni {
			create juliet number: 5 {
				location <- rnd({0, 0}, {1000, 1000});
			}
		}
	}
}

species voroni {
	
	
	reflex update_voronoi {
		list<geometry> voronois <- voronoi(juliet collect each.location);
		ask juliet {
			shape <- geometry(voronois where (each overlaps location));
		}
	}
	
	species juliet{
		reflex move {
			location <- location + rnd({-0.1, -0.1}, {0.1, 0.1});
		}
	}
	
	init {
		
	}
	
	aspect default {
		draw circle(50);
		ask members {draw circle(50) color: #green;}
		ask members {draw shape border: #black;}
	}
}

experiment Test type: gui {
	output {
		display main type: opengl {
			species voroni;
			//species juliet;
		}
	}
}