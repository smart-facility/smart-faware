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
	
	
	reflex update_voronoi{
		list<point> points <- [];
		loop id over: juliet {
			points <- points + id.location;
		}
		list<geometry> voronois <- voronoi(points);
		ask juliet {
			shape <- geometry(voronois where (each overlaps location));
		}
	}
	
	species juliet{
		reflex move {
			location <- location + rnd({-10, -10}, {10, 10});
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