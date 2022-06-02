/***
* Name: dbauto
* Author: Nate
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model dbauto

global {
	//setup to grab bounds of catchment from database
	map<string,string> BOUNDS <- [  
    //'srid'::'32648',
    'host'::'floodaware-db.postgres.database.azure.com',                                
    'dbtype'::'postgres',
    'database'::'floodaware',
    'port'::'5432',                             
    'user'::'postgres',
    'passwd'::'1234',
    'select'::'SELECT st_asbinary(st_transform(st_expand(st_envelope(geom),0.001),28356)), id FROM sensors WHERE id = 10'];
    geometry shape <- envelope(BOUNDS);
    
    map<string, string> POSTGRES <- [
     'host'::'floodaware-db.postgres.database.azure.com',
     'dbtype'::'postgres',
     'database'::'floodaware',
     'port'::'5432',
     'user'::'postgres',
     'passwd'::'1234'];
    
	date starting_date <- date('20200207');
	float step <- 5#mn;
	
	float LAG_PARAM <- 1.61;
	
	init {
		create topo;
		
		ask [land[10506], land[10507], land[10403]] {
			//source <- true;
			//do take_water(10000.0);
		}
	}
	
	reflex rain {
		ask land parallel: true {
			do take_water(20#mm*shape.area);
		}
	}
	
	
	reflex update_water {
		loop cell over: shuffle(land) sort_by each.height {
			ask cell {do give_water;}
		}
	}
}

species topo skills: [SQLSKILL] {
	init {
		list c <- select(params: POSTGRES,
			select: "WITH
	extent AS (SELECT st_expand(st_envelope(geom),0.0005) AS geom, id FROM sensors WHERE id = 10)
	SELECT st_asbinary(st_transform(geom, 28356)) AS geom, val FROM high_res, st_pixelaspolygons(st_resample(st_clip(st_transform(rast, 4326), (SELECT geom FROM extent)),100,100))"
		);
		create subtopo from: c with: [shape: "geom", val: "val"];
		
	}
	
	species subtopo {
		float val;
	}
	
	aspect default {
		ask subtopo {
			draw shape border: #black color: #lightgreen depth: val;//*2.5;
		}
	}
}



grid land width: 50 height: 50 neighbors: 8 {
	float altitude;
	float height;
	bool source;
	float constant <- LAG_PARAM*((self.shape.area/#km^2)^0.57)#h;
	
	init {
		altitude <- grid_value;
		create water from: [shape] {
			location <- location + {0, 0, altitude};
		}
		height <- altitude + water[0].level;
	}
	
	action give_water {
		float storage <- water[0].storage;
		list<land> flow_to <- neighbors where (each.height < height);
		float total_diff <- sum(flow_to collect (height - each.height));
		float flow_amm <- min([storage, step*(storage/constant)^(1/0.77)]);
		
		ask flow_to {
			float proportion <- (myself.height - height)/total_diff;
			do take_water(proportion*flow_amm);
		}
		
		if !source {
			do take_water(-flow_amm);
		}
	}
	
	action take_water (float amount) {
		water[0].storage <- water[0].storage + amount;
		water[0].level <- water[0].storage/shape.area;
		height <- altitude + water[0].level;
	}
	
	species water {
		float storage min: 0.0;
		float level;
	}
	
	aspect default {
		draw shape color: #lightgreen depth: altitude;
		ask water {
			draw shape color: rgb(0, 0, 255, int((((bool(level) ? 0.02 : 0) + level/2.5))*255)) depth: level;
		}
	}
}

experiment Visualise type: gui {
	output {
		display main type: opengl {
			//species land refresh: false;
			species topo;
		}
	}
}