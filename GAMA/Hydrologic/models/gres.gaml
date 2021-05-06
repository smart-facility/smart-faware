/***
* Name: gres
* Author: nhutchis
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model gres

/* Insert your model definition here */

global {
	file experiments <- folder('../../../data/experiments');
	file parameters <- json_file(experiments.path+'/test_experiment.json');
	file db_param <- json_file(experiments.path+'/'+parameters['data']['db']);
	
	list data;
	init {
		create db;
	}
}

species db skills: [SQLSKILL] {
	init {
		list c <- select(params:db_param.contents, select:'SELECT st_asbinary(geom), name, regr[1] AS const, regr[2] AS x1, regr[3] AS x2, regr[4] AS x3  FROM transects');
		write c;
		world.data <- c;
	}
}

experiment test {
	
}