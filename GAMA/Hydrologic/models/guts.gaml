/***
* Name: Wollongong_flood_model_13
* Author: anton bommel
* Description: 
* Tags: Tag1, Tag2, TagN
***/

//Final model for discret version at the 10/12/2019. This version have rainfield grid, infiltration, impervious surface, input value for rain in a csv file and csv output
model Wollongong_flood_model_13


/*------------------------------------------------------------------------------------------------------------------------------------------------------
 ******************************************************************************************************************************************************* 
 ***** GLOBAL ******************************************************************************************************************************************
 ******************************************************************************************************************************************************* 
 ------------------------------------------------------------------------------------------------------------------------------------------------------*/

global{
	bool parallel <- true;
	
	//set the duration of 1 step
	float step <- 10#mn/74;
	
		//Shapefile for the catchments
   file catchments_shapefile <- file("../../../data/gis/catchment_shape.shp");
	
	//rain information linked to each catchment 
   //file rain_csv <- file("../../../data/rain/rainfield_woll.csv");
   file rain_csv <- file("../../../data/gong_csv.csv");
	//Data elevation file
   file dem_file <- file("../../../data/gis/elevation_grid.tif");
   file rain_tif <- file("../../../data/gis/rain_grid.tif");
   float resolution <- 10 #m;
   //Data of impervious area
   file impervious_shapefile <- file("../../../data/gis/impervious_shape.shp");
	//Shape of the environment using the dem file
   geometry shape <- envelope(rain_tif);
   
   //output of catchment (visual mostly)
   list<float> hydro ; //to show the flow for each catchment
   list<float> total_volume_global ; //to show the volume contain in each catchment
   float global_volume; //to stop the program
   //the differents lag parameters
   float Lag_parameter_C <- 1.61;
   float Impervious_Lag_parameter <- 0.1;
   float Stream_Lag_factor <- 1.0;
   
   float max_rain <- 0.0;
   
   //List for lagtime and catchment for continue flow
   list<float> Lagtime_global;
   list<catchment> catchment_for_each_lagtime;
   
   /*------------------------------------------------------------------------------------------------------------------------------------
     Precipitation
    -----------------------------------------------------------------------------------------------------------------------------------*/
   float flat_infiltration_cell <- 5 #mm;
   float proportion_infiltration <- 0.1;
   int end_precipitation; // for the speed in the model and stop the model
	
	/*-----------------------------------------------------------------------------------------------------------------------------------
	 Initialisation 
	 ----------------------------------------------------------------------------------------------------------------------------------*/
	init{
		do init_catchment;
		do init_cells;
		do nbcell_catchment;
		do init_rain;
	}
	
	
	//create the grid and link the cell with the differents catchment and rain grid
	action init_cells{
    
      // Link each cell with its catchment (important)
      loop position over: catchment {
      	ask Land_Unit overlapping position{
      		catchment_linked <- position.name;
      	}
      }
      
      //find Land_Unit which are not in the catchment (the program will not take them into account)
      ask Land_Unit where (each.catchment_linked = nil){
      	do die;
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
  }
  
  

  
  // give each line of the csv file for rain
  action init_rain{
  	//creation of a matrix with all the rain information
  	matrix rain <- matrix(rain_csv);
  	// give for each rain cell his rain info for the simulation
  	loop id from:0 to: rain.rows -1{
  		ask rain_cell{
  			// check if the name of rain cells the same that the one in the csv file
  			if (string(id) = replace(name, "rain_cell", "")){
  				//create a list with the rain information (is the amount of water that arrive during the step in mm)
  				loop lp from:0 to: rain.columns-4{
  					precipitation_per_step <- precipitation_per_step + rain[lp+3,id];
  				}
  				if ((precipitation_per_step max_of each) > max_rain) {max_rain <- precipitation_per_step max_of each;}
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
   			float precip <- (precipitation_per_step at cycle)/1000;
   			loop rain over: Lands_cells{
   				//give at each Land_Unit the amount of water store in the rain cell for this step
   				rain.precipitation_recieved<- precip;// in m
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
    	// calculation of chanel lagtime
    	do channel_calculation;
      }
   }
   

   
   // Prepare to flow all the water that have to flow using the lagtime
   reflex time_check{
   	ask catchment{
   		// we count the number of volume that flow this turn
   		int nb_lag_time <- length(lag_time_stored where (each < time+step));
   		// create a list of all the volume that will flow during this step
   		loop times: nb_lag_time{
   			//store in the list all the volume that will flow
   			volume_to_flow <- volume_to_flow + volume_stored at 0;
   			// remove the everything that will flow during this turn from the list
   			remove from: volume_stored index:0;
   			remove from: lag_time_stored index:0;
   		}
   	}
   }
   
   // Send the water from one catchment to another one
   reflex flow{
   	ask catchment sort_by each.ID{
   		//store the volume for graphic and output purpose
   		
   		//check if we have to flow something
   		if volume_to_flow != 0.0{
   			//if this catchment is the last, we remove the water from the model
   			if downstream = "out"{
   				volume_to_flow <- 0.0;
   			}
   			//if it is not the last catchment we send the water to the next catchment
   			else{
   				// we remove the water for the upper catchment 
   				float flow <- volume_to_flow;
   				volume_to_flow <- 0.0;
   				// we send the water to the next catchment
   				ask catchment where (each.ID=int(downstream)){
   					volume_stock <- volume_stock + flow;
   				}
   			}
   		}
   	}
   }
   
   
   // reflex to save the data into csv file
   reflex save_csv{
   	//check if we don't have anymore flow
      if global_volume = 0.0 and cycle > end_precipitation{
   	     ask catchment{
   	     	//save the information into a csv file for each catchment
   			save ["common","common",ID,debit_volume_simulation] to: "../output/test.csv" rewrite: false type: "csv";
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
	
      //calculation of runoff lagtime //optimise this section, factorise stuff
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
      		//calculation of the channel lagtime using WBNM equation and the exact time
    		float Lag_time_channel <- time + Stream_Lag_factor * 0.6 * Lag_parameter_C * (resolution*resolution/1000/1000*nb_cells)^(0.57) * (volume_stock/step)^(-0.23)*3600;
    	    //store the equation in the list of lagtime of the catchment and sort it by lagtime
    	    lag_time_stored <- lag_time_stored + Lag_time_channel;
    	    lag_time_stored <- lag_time_stored sort_by (each);
    	    //find where this lagtime have been stored in the list
    	    int localisation <- lag_time_stored index_of Lag_time_channel;
    	    //store the volume corresponding to this lagtime in the list of volume stored at the same position that the lagtime
    	    add item:volume_stock to: volume_stored at: localisation;
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


 grid rain_cell file: rain_tif {
 	list<Land_Unit> Lands_cells;
 	list<float> precipitation_per_step;
 	rgb colour <- #white update: rgb(255-int(log((precipitation_per_step at cycle)*10/max_rain+1)*255), 255-int(log((precipitation_per_step at cycle)*10/max_rain+1)*255), 255);
 	aspect cells{
		draw shape color: colour;
	}
 }

/*------------------------------------------------------------------------------------------------------------------------------------------------------
 ******************************************************************************************************************************************************* 
 ***** EXPERIMENT **************************************************************************************************************************************
 ******************************************************************************************************************************************************* 
 ------------------------------------------------------------------------------------------------------------------------------------------------------*/


experiment Run type: gui {
	//parameter that can be modified (for now we can't change the file like csv and shp) 
	parameter "duration of one step (in s)" var:step category:"global";
	parameter "distance of 1 side of Land_Unit (in m)" var:resolution category:"global";
	parameter "Lag parameter C" var:Lag_parameter_C category:"Lag parameters" min:1.3 max:1.8;
	parameter "Impervious Lag parameter" var:Impervious_Lag_parameter category:"Lag parameters" min:0.0 max:1.0;
	parameter "Stream Lag factor" var:Stream_Lag_factor category:"Lag parameters" min:0.0;
	parameter "The amount of water that can infiltrate (in m)" var:flat_infiltration_cell category:"Precipitation" min:0.0;
	parameter "The proportion of water that can infiltrate for pervious area" var:proportion_infiltration category:"Precipitation" min:0.0 max:1.0;
	
}