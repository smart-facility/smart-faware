/***
* Name: Wollongong_flood_model_12_without_visual
* Author: anton bommel
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Wollongong_flood_model_12_without_visual
/*------------------------------------------------------------------------------------------------------------------------------------------------------
 ******************************************************************************************************************************************************* 
 ***** GLOBAL ******************************************************************************************************************************************
 ******************************************************************************************************************************************************* 
 ------------------------------------------------------------------------------------------------------------------------------------------------------*/

global{
	bool parallel <- true;
	
	//set the duration of 1 step
	float step <- 5 #mn;
	
	//Shapefile for the catchments
   file catchments_shapefile <- file("C:/Users/anton bommel/Documents/SupAgro/STAGE 2A/travail/shape_for_gama/shapefile_test_modele2/catchment_fairy_meadow.shp");
	
	//rain information linked to each catchment 
   file rain_csv <- file("C:/Users/anton bommel/Documents/SupAgro/STAGE 2A/travail/shape_for_gama/shapefile_test_modele2/precipitation_test.csv");
	//Data elevation file
   file dem_file <- file("C:/Users/anton bommel/Documents/SupAgro/STAGE 2A/travail/shape_for_gama/shapefile_test_modele2/DEM_catchment_fairy_meadow_10m_resolution.tif");
   float resolution <- 10 #m;
   //Data of impervious area
   file impervious_shapefile <- file("C:/Users/anton bommel/Documents/SupAgro/STAGE 2A/travail/shape_for_gama/shapefile_test_modele2/Imperviousness/only_100.shp");
	//Shape of the environment using the dem file
   geometry shape <- envelope(dem_file);
   
   //output of catchment (visual mostly)
   list<float> hydro ; //to show the flow for each catchment
   list<float> total_volume_global ; //to show the volume contain in each catchment
   float global_volume; //to stop the program
   //the differents lag parameters
   float Lag_parameter_C <- 1.61;
   float Impervious_Lag_parameter <- 0.1;
   float Stream_Lag_factor <- 1.0;
   
   //List for lagtime and catchment for continue flow
   float current_time;
   list<float> Lagtime_global;
   list<catchment> catchment_for_each_lagtime;
   
   /*------------------------------------------------------------------------------------------------------------------------------------
     Precipitation
    -----------------------------------------------------------------------------------------------------------------------------------*/
   float flat_infiltration_cell <- 5 #mm; 
   float proportion_infiltration <- 0.1;
   int end_precipitation; // for the speed in the program and stop the program
	
	/*-----------------------------------------------------------------------------------------------------------------------------------
	 Initialisation 
	 ----------------------------------------------------------------------------------------------------------------------------------*/
	init{
		do init_catchment;
		do init_cells;
		do nbcell_catchment;
		do init_rain;
		do init_save;
	}
	
	
	//create the grid and link the cell with the differents catchment and rain grid
	action init_cells{
		// Give at each Land_Unit cell his altitude and their neighbors, not usefull in this version.
      ask Land_Unit parallel: parallel {
         altitude <- grid_value;
         neighbors_cells <- (self neighbors_at 1) ;
      }
      
      // Link each cell with its catchment (important)
      loop position over: catchment {
      	ask Land_Unit overlapping position{
      		catchment_linked <- position.name;
      	}
      }
      
      //find Land_Unit which are not in the catchment
      ask Land_Unit where (each.catchment_linked = nil){
      	loop remov over:neighbors_cells{
      		// we remove the from the list of neighbors cells because they will die, not usefull in this version.
      		remove self from:remov.neighbors_cells;
      	}
      }
      //find Land_Unit which are not in the catchment (the program will not take them into account)
      ask Land_Unit where (each.catchment_linked = nil){
      	do die;
      }
       
      //find the cell of the limit of a catchment and give them the catchment that they touch, not usefull in this version.
      ask Land_Unit parallel: parallel  {
      	loop limit over: neighbors_cells {
      		if (limit.catchment_linked != catchment_linked and limit_cell != true){
      			limit_cell <- true;
      			neighbor_catchment <- limit.catchment_linked;
      		}
      	}
      }
      
      //Link each cell with its rain zone (important)
      loop position over: rain_cell {
      	ask Land_Unit overlapping position{
      		rain_cell_linked <- position.name;
      	}
      }
      
      //find impervious cells (important)
      geometry impervious <- geometry(impervious_shapefile);
      ask Land_Unit overlapping impervious{
      	is_impervious <- true;
      }
   }   
   
   //create the differents catchments
   action init_catchment{
   	// create the catchments and give them their initialisation information
   	loop lp over: catchments_shapefile{
      create catchment from: [lp]  {
      	//give the information store in the shapefile to the catchment
      	downstream <- lp get "DOWNSTREAM";
      	ID <- int(lp get "ID");
      }
    }
    // Find the catchment that are in head (only receive water from rain), not really usefull now
    ask catchment{
    	loop ishead over:catchment{
    		if ishead.downstream = string(ID){
    			head <- false;
    		}
    	}
     }
     
  }
  
  

  
  // give each line of the csv file for rain
  action init_rain{
  	//creation of a matrix with all the rain information
  	matrix rain <- matrix(rain_csv);
  	// give for each rain cell his rain info for the simulation
  	loop id from:0 to: rain.rows -1{
  		ask rain_cell{
  			// check if the name of rain cells the same that the one in the csv file
  			if int(rain[2,id])= int(name){
  				//create a list with the rain information (is the amount of water that arrive during the step in mm)
  				loop lp from:0 to: rain.columns-4{
  					precipitation_per_step <- precipitation_per_step + rain[lp+3,id];
  				}
  			}
  		}
  	}
  	//Store an approximation of the number of step that it will be raining (to help to stop the model and be faster)
  	end_precipitation <- rain.columns;
  	
  	//link each rain grid with the Land_Unit composing it
  	loop rain over:rain_cell{
  		ask Land_Unit {
  			if rain_cell_linked = rain.name{
  				rain.Lands_cells <- rain.Lands_cells + self;
  			}
  		}
  	 }
  	
  }

//prepare the list to save everything
  action init_save{
  	ask catchment{
  		//this list is for visualisation in GAMA, not really usefull for the non visual model
  		 hydro <- hydro + 0.0;
   		 total_volume_global <- total_volume_global + 0.0;
  	}
  }
  
  // give a list of Land_Unit cell and count the number of cell for each catchment and the quantity of water that can be stored
  action nbcell_catchment{
  	loop catchm over: catchment{
  		ask Land_Unit {
  			if catchment_linked = catchm.name{
  				catchm.cell_of_the_catchment <- catchm.cell_of_the_catchment + self; //add the agent Land_Unit to list of Land_Unit composing the catchment
  			}
  		}
  		catchm.nb_cells <- length(catchm.cell_of_the_catchment); // count the number of agent of the list
  	}
  	
  	//count the number of cell that are impervious for each catchment
  	ask catchment{
  		loop imp over: cell_of_the_catchment{
  			if imp.is_impervious = true{
  				nb_cells_impervious <- nb_cells_impervious + 1;
  			}
  		}
  	}
  }
  
   /*-----------------------------------------------------------------------------------------------------------------------------------
   Reflex 
   ----------------------------------------------------------------------------------------------------------------------------------*/
   //calculation of precipitation for each catchment 
   reflex Precipitation{
   		//give the precipitation for each cells
   	ask rain_cell{
   		//run only if it will rain
   		if cycle < length(precipitation_per_step){
   			loop rain over: Lands_cells{
   				//give at each Land_Unit the amount of water store in the rain cell for this step
   				rain.precipitation_recieved<- (precipitation_per_step at cycle)/1000;// in m
   			}
   		}
   	}	
   }
   
   //infiltration part
   reflex infiltration{
   	//run only if we still have precipitation
   	if cycle < end_precipitation{
   		ask Land_Unit{
   			//check if the soil is saturated
   			if water_infiltrate != flat_infiltration_cell{
   				//if it not saturated, check the total amount of water now in the cell and compare it with its maximum retention
   				float diff_inf <- water_infiltrate + precipitation_recieved - flat_infiltration_cell;
   				// all the water that came into the cell can be infiltrate
   				if diff_inf <= 0.0{
   					water_infiltrate <- water_infiltrate + precipitation_recieved;
   					precipitation_recieved <- 0.0;
   				}
   				//Just a part of the water that arrive can be store
   				else{
   					water_infiltrate <- flat_infiltration_cell;
   					precipitation_recieved <- diff_inf;
   				}
   			}
   			//remove constant infiltration for pervious surface only
   			if is_impervious = false{
   				precipitation_recieved <- precipitation_recieved * (1 - proportion_infiltration);
   			}
   			// transfert the rest of the water into m3
   			precipitation_recieved <- precipitation_recieved * resolution * resolution;
   		}
   	}
   }
   
   //get the amount of water for impervious and pervious surface / tansfert the water from the Land_Unit to the catchment
   reflex get_flat_precipitation{
   	//run only if we still have precipitation
   	if cycle < end_precipitation{
   		ask catchment{
   			//calculation of the total volume that rain on the catchment
   			loop rain over: cell_of_the_catchment{
   				if rain.is_impervious = true{
   					//add the amount of water store in the impervious Land_Unit cell
   					runoff_volume_impervious <- runoff_volume_impervious + rain.precipitation_recieved;
   				}
   				else{
   					//add the amount of water store in the pervious Land_Unit cell
   					runoff_volume_pervious <- runoff_volume_pervious + rain.precipitation_recieved;
   				}
   			// Put the total amount of water in the cell at 0.
   			rain.precipitation_recieved <- 0.0;
   			}
   		}
   	}
   }
   
   //Reflex to Lag time calculation + store them
   reflex lagtime_calculation{
    ask catchment{
    	// calculation of runoff lagtime
    	do runoff_calculation;
    	// calculation of chanel lagtime (not really usefull at this location for this version)
    	do channel_calculation;
      }
   }
   

   
   // Prepare to flow all the water that have to flow using the lagtime
   reflex time_check{
   	//create the list for the start of the step
   	ask catchment{
   		//calculate the number of lagtime that will happen during this step
   		int nb_lag_time <- length(lag_time_stored where (each < time+step));
   		int count <-0;
   		loop times: nb_lag_time{
   			//take the value of lagtime store at the count position in the list of lagtime
   			float to_add <- lag_time_stored at count;
   			//store the lagtime in the list of lagtime happening during this step and sort it by lagtime
   			Lagtime_global <- Lagtime_global + to_add;
    	    Lagtime_global <- Lagtime_global sort_by (each);
    	    //find where this lagtime have been stored in the list
    	    int localisation <- Lagtime_global index_of to_add;
    	    //link the lagtime with the catchment which have this lagtime
    	    catchment_for_each_lagtime <- catchment_for_each_lagtime + self;
    	    //add one to count value to pass to the next position
    	    count <- count + 1;
   		}
   		// manage all the lagtime during the step
   		//here we take the first value of each list we flow the volume and remove it from the list
   		loop while:length(Lagtime_global)!=0{
   			//get the time when the volume will flow
   			current_time <- Lagtime_global at 0;
   			//get the agent who is flowing
   			agent agent_flowing <- catchment_for_each_lagtime at 0;
   			ask agent_flowing{
   				//take the amount of water that will flow
   				volume_to_flow <- volume_stored at 0;
   				//add this value to the amount of water that have been store this step
   				total_flowed <- total_flowed + volume_to_flow;
   				//remove the current lagtime and volume that is flowing to the next catchment from the list of this catchment
   				remove from: volume_stored index:0;
   				remove from: lag_time_stored index:0;
   				// if this catchment is the last one, remove the water from the model
   				if downstream = "out"{
   					volume_to_flow <- 0.0;
   				}
   				// send the water to the next catchment
   				else{
   					//store ths value in the global agent and remove it from the catchment
   					float flow <- volume_to_flow;
   					volume_to_flow <- 0.0;
   					ask catchment where (each.ID=int(downstream)){
   						//the catchment downstream receive the water and calculate a lagtime
   						volume_stock <- flow;
   						do channel_calculation;
   					}
   				}
   			}
   		//remove the lagtime and the catchment from the list 
   		remove from: Lagtime_global index:0;
   		remove from: catchment_for_each_lagtime index:0;
   		}
   	 }
   }
   
   // Send the water from one catchment to another one (only for information for this version)
   reflex flow{
   	ask catchment sort_by each.ID{
   		//store the amount of outflow for graphic interface
   		put total_flowed in: hydro key: ID-1;
   		//store the outflow for the list of outflow that happen for each step 
   		debit_volume_simulation <- debit_volume_simulation + [total_flowed/step];
   		//clean the counter
   		total_flowed <- 0.0;
   	}
   }
   
   // a reflex to get some information for graphic purpose and to see if we can stop the program
   reflex info{
   	//clean the counter
   	global_volume <- 0.0;
   	  ask catchment{
   	  	//clean the counter 2 
   	  	total_volume <- 0.0;
   	  	//count the amount of water store in the catchment
   	  	loop total over:volume_stored{
   	  		total_volume <- total_volume + total;
   	  	}
   	  	//store the volume at each step in a list
   	  	total_volume_simulation <- total_volume_simulation + [total_volume];
   	  	//count the volume of water in th whole catchment
   	  	global_volume <- global_volume + total_volume;
   	  }
   	  //store the volume of water in the catchment for graphic interface
   	  ask catchment sort_by each.ID{
   		put total_volume in: total_volume_global key: ID-1;
   	  }
   }
   
   // a reflex for graphic output to update the color of a catchment, not really usefull for the non visual model
   reflex graphic_output{
   	ask catchment{
   		do update_color;
   	}
   }
   
   // reflex to save the data into csv file
   reflex save_csv{
   	//check if we don't have anymore flow
      if global_volume = 0.0 and cycle > end_precipitation{
   	     ask catchment{
   	     	//save the information into a csv file for each catchment
   			save ["common","common",ID,debit_volume_simulation] to: "C:/Users/anton bommel/Documents/SupAgro/STAGE 2A/travail/shape_for_gama/shapefile_test_modele2/sortie/test.csv" rewrite: false type: "csv";
   		 }
   		 do pause;
   	  }
   }
   
}

/*------------------------------------------------------------------------------------------------------------------------------------------------------
 ******************************************************************************************************************************************************* 
 ***** SPECIES *****************************************************************************************************************************************
 ******************************************************************************************************************************************************* 
 ------------------------------------------------------------------------------------------------------------------------------------------------------*/

     /*-----------------------------------------------------------------------------------------------------------------------------------
	 Catchment 
	 ----------------------------------------------------------------------------------------------------------------------------------*/


species catchment {
	int ID;
	int nb_cells;
	int nb_cells_impervious <- 0;
	list<Land_Unit> cell_of_the_catchment;
	float total_precipitation_volume ;
	float runoff_volume_impervious;
	float runoff_volume_pervious;
	string downstream ;
	bool head <- true;
	list<float> lag_time_stored;
	list<float> volume_stored;
	float volume_to_flow <- 0.0;
	float total_flowed <- 0.0;
	float volume_stock <- 0.0;
	float total_volume <- 0.0;
	list<float> total_volume_simulation <- [0.0];
	list<float> debit_volume_simulation <- [0.0];
	
	
	//graphic part
	rgb catch_color <- rgb(255,255,255);
	aspect catchments{
		draw shape color: catch_color;
	}
	
	//Update the color of the cell (only for visual purpose in GAMA)
      action update_color { 
         int val_water <- 0;
         val_water <- max([0, min([255, int(255*(total_volume/ (nb_cells*resolution*resolution)*20))])]) ;  
         catch_color <- rgb([255-val_water, 255-val_water, 255]);
      }
      
      //calculation of runoff lagtime
      action runoff_calculation{
      	// calculation of runoff for pervious surface
      	if runoff_volume_pervious != 0.0{
      		//calculation of the runoff lagtime using WBNM equation
    		float Lag_time_runoff <- time + Lag_parameter_C * (resolution*resolution/1000/1000*(nb_cells-nb_cells_impervious))^(0.57) * (runoff_volume_pervious/step)^(-0.23) * 3600;
    		//store the equation in the list of lagtime of the catchment and sort it by lagtime
    	    lag_time_stored <- lag_time_stored + Lag_time_runoff;
    	    lag_time_stored <- lag_time_stored sort_by (each);
    	    //find where this lagtime have been stored in the list
    	    int localisation <- lag_time_stored index_of Lag_time_runoff;
    	    //store the volume corresponding to this lagtime in the list of volume stored at the same position that the lagtime
    	    add item:runoff_volume_pervious to: volume_stored at: localisation;
    	    //clean the volume
    	    runoff_volume_pervious <- 0.0;
    	}
    	// calculation of runoff for impervious surface
      	if runoff_volume_impervious != 0.0{
      		//calculation of the impervious runoff lagtime using WBNM equation
    		float Lag_time_runoff <- time + Impervious_Lag_parameter * Lag_parameter_C * (resolution*resolution/1000/1000*nb_cells_impervious)^(0.25) * 3600;
    	    //store the equation in the list of lagtime of the catchment and sort it by lagtime
    	    lag_time_stored <- lag_time_stored + Lag_time_runoff;
    	    lag_time_stored <- lag_time_stored sort_by (each);
    	    //find where this lagtime have been stored in the list
    	    int localisation <- lag_time_stored index_of Lag_time_runoff;
    	    //store the volume corresponding to this lagtime in the list of volume stored at the same position that the lagtime
    	    add item:runoff_volume_impervious to: volume_stored at: localisation;
    	    //clean the volume
    	    runoff_volume_impervious <- 0.0;
    	}
      }
      
      // calculation of runoff for channel
      action channel_calculation{
      	if volume_stock != 0.0{
      		//calculation of the channel lagtime using WBNM equation and the exact time (can be in the middle of the step)
    		float Lag_time_channel <- current_time + Stream_Lag_factor * 0.6 * Lag_parameter_C * (resolution*resolution/1000/1000*nb_cells)^(0.57) * (volume_stock/step)^(-0.23)*3600;
    		//store the equation in the list of lagtime of the catchment and sort it by lagtime
    	    lag_time_stored <- lag_time_stored + Lag_time_channel;
    	    lag_time_stored <- lag_time_stored sort_by (each);
    	    //find where this lagtime have been stored in the list
    	    int localisation <- lag_time_stored index_of Lag_time_channel;
    	    //store the volume corresponding to this lagtime in the list of volume stored at the same position that the lagtime
    	    add item:volume_stock to: volume_stored at: localisation;
    	    //if the flow will happen before the end of the step, put it on the list of flow in this step
    	    if Lag_time_channel < time+step{
    	    	//store the lagtime in the list of lagtime happening during this step and sort it by lagtime
    	    	Lagtime_global <- Lagtime_global + Lag_time_channel;
    	    	Lagtime_global <- Lagtime_global sort_by (each);
    	    	//find where this lagtime have been stored in the list
    	    	int localisation <- Lagtime_global index_of Lag_time_channel;
    	    	//link the lagtime with the catchment which have this lagtime
    	    	catchment_for_each_lagtime <- catchment_for_each_lagtime + self;
    	    }
    	    //clean the volume
    	    volume_stock <- 0.0;
    	 }
      }
}
     /*-----------------------------------------------------------------------------------------------------------------------------------
	 elevation_cell
	 ----------------------------------------------------------------------------------------------------------------------------------*/



grid Land_Unit  file: dem_file neighbors: 8 frequency: 0  use_regular_agents: false use_individual_shapes: false use_neighbors_cache: false schedules: [] parallel: parallel {
	float altitude;
	string catchment_linked;
	string rain_cell_linked;
	float water_infiltrate <- 0.0;
	float water_height <- 0.0;
	bool limit_cell <- false;
	bool is_impervious <- false;
	string neighbor_catchment;
	list<Land_Unit> neighbors_cells;
	float precipitation_recieved;
	aspect cells{
		draw shape color: rgb(0,0,0);
	}
}

	 /*-----------------------------------------------------------------------------------------------------------------------------------
	 rain_cell
	 ----------------------------------------------------------------------------------------------------------------------------------*/


 grid rain_cell cell_height: 1000 cell_width: 1000 {
 	list<Land_Unit> Lands_cells;
 	list<float> precipitation_per_step;
 	aspect cells{
		draw shape color: rgb(0,255,255);
	}
 }

/*------------------------------------------------------------------------------------------------------------------------------------------------------
 ******************************************************************************************************************************************************* 
 ***** EXPERIMENT **************************************************************************************************************************************
 ******************************************************************************************************************************************************* 
 ------------------------------------------------------------------------------------------------------------------------------------------------------*/


experiment Run type: gui {
	//parameter that can be modified (and for now are not file like csv and shp) 
	parameter "duration of one step (in s)" var:step category:"global";
	parameter "distance of 1 side of Land_Unit (in m)" var:resolution category:"global";
	parameter "Lag parameter C" var:Lag_parameter_C category:"Lag parameters" min:1.3 max:1.8;
	parameter "Impervious Lag parameter" var:Impervious_Lag_parameter category:"Lag parameters" min:0.0 max:1.0;
	parameter "Stream Lag factor" var:Stream_Lag_factor category:"Lag parameters" min:0.0;
	parameter "The amount of water that can infiltrate (in m)" var:flat_infiltration_cell category:"Precipitation" min:0.0;
	parameter "The proportion of water that can infiltrate for pervious area" var:proportion_infiltration category:"Precipitation" min:0.0 max:1.0;
}