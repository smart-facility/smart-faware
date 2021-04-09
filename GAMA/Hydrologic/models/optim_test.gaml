/***
* Name: optimtest
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model optimtest

global {
	int no;
	int nums_len <- 1;
	
	init {
		create man number: 10000;
		
	}
	
	reflex update {
		no <- length(man where (each.sumnum > 50));
		write no;
	}
}

species man {
	int sumnum <- 0;
	list nums;
	
	init {
		loop i from: 1 to: nums_len {
			nums <+ rnd(50);
		}
		//write nums;
		
		loop i over: nums {
			sumnum <- sumnum + int(i);
		}
		
		//write sumnum;
	}
}

experiment test type: batch until: time > 10 repeat: 10{
	method exhaustive
	minimize: no;
	
	parameter "Length" var: nums_len min: 1 max: 50 step: 1;
}