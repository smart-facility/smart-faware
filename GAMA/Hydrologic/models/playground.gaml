/***
* Name: playground
* Author: Nate
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model playground

/* Insert your model definition here */

global {
	
}

species thing {
	rgb colour <- rgb(rnd(255), rnd(255), rnd(255));
	
	aspect default {
		draw shape color: colour;
	}
}

grid thingo parent: thing width: 10 height: 10{
	
}

experiment yes type: gui {
	output {
		display yes {
			species thingo;
		}
	}
}