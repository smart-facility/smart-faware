/***
* Name: Wollongong_flood_model_13
* Author: anton bommel
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Wollongong_flood_model_13


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
   file catchments_shapefile <- file("../shape/catchment and node shapefile/catchment_fairy_meadow.shp");
	
	//rain information linked to each catchment 
   file rain_csv <- file("../shape/precipitation_test.csv");
	//Data elevation file
   file dem_file <- file("../shape/raster elevation/DEM_catchment_fairy_meadow_10m_resolution.tif");
   float resolution <- 10 #m;
   //Data of impervious area
   file impervious_shapefile <- file("../shape/impervious area/only_100.shp");
	//Shape of the environment using the dem file
   geometry shape <- envelope(dem_file);
   
   //output of catchment
   list<float> hydro ;
   list<float> total_volume_global ;
   float global_volume;
   //the differents lag parameters
   float Lag_parameter_C <- 1.61;
   float Impervious_Lag_parameter <- 0.1;
   float Stream_Lag_factor <- 1.0;
   
   //List for lagtime and catchment for continue flow
   list<float> Lagtime_global;
   list<catchment> catchment_for_each_lagtime;
   
   /*------------------------------------------------------------------------------------------------------------------------------------
     Precipitation
    -----------------------------------------------------------------------------------------------------------------------------------*/
   float flat_infiltration_cell <- 5 #mm;
   float proportion_infiltration <- 0.1;
   int end_precipitation;
	
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
		// Give at each Land_Unit cell his altitude and their neighbors
      ask Land_Unit parallel: parallel {
         altitude <- grid_value;
         neighbors_cells <- (self neighbors_at 1) ;
      }
      // Link each cell with its catchment
      loop position over: catchment {
      	ask Land_Unit overlapping position{
      		catchment_linked <- position.name;
      	}
      }
      
      //remove Land_Unit which are not in the catchment
      ask Land_Unit where (each.catchment_linked = nil){
      	loop remov over:neighbors_cells{
      		remove self from:remov.neighbors_cells;
      	}
      }
      ask Land_Unit where (each.catchment_linked = nil){
      	do die;
      }
       
      //find the cell of the limit of a catchment and give them the catchment that they touch
      ask Land_Unit parallel: parallel  {
      	loop limit over: neighbors_cells {
      		if (limit.catchment_linked != catchment_linked and limit_cell != true){
      			limit_cell <- true;
      			neighbor_catchment <- limit.catchment_linked;
      		}
      	}
      }
      
      //Link each cell with its rain zone
      loop position over: rain_cell {
      	ask Land_Unit overlapping position{
      		rain_cell_linked <- position.name;
      	}
      }
      
      //find impervious cells
      geometry impervious <- geometry(impervious_shapefile);
      ask Land_Unit overlapping impervious{
      	is_impervious <- true;
      }
   }   
   
   //create the differents catchments
   action init_catchment{
   	// create the catchments and give them their init information
   	loop lp over: catchments_shapefile{
      create catchment from: [lp]  {
      	downstream <- lp get "DOWNSTREAM";
      	ID <- int(lp get "ID");
      }
    }
    // Find the catchment that are in head
    ask catchment{
    	loop ishead over:catchment{
    		if ishead.downstream = string(ID){
    			head <- false;
    		}
    	}
     }
     
  }
  
  

  
  // give each line of the csv
  action init_rain{
  	//creation of a matrix with all the rain information
  	matrix rain <- matrix(rain_csv);
  	// give for each catchment his rain info for the simulation
  	loop id from:0 to: rain.rows -1{
  		ask rain_cell{
  			if int(rain[2,id])= int(name){
  				loop lp from:0 to: rain.columns-4{
  					precipitation_per_step <- precipitation_per_step + rain[lp+3,id];
  				}
  			}
  		}
  	}
  	
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
  		 hydro <- hydro + 0.0;
   		 total_volume_global <- total_volume_global + 0.0;
  	}
  }
  
  // give a list of Land_Unit cell and count the number of cell for each catchment and the quantity of water that can be stored
  action nbcell_catchment{
  	loop catchm over: catchment{
  		ask Land_Unit /*where (each.catchment_linked = catchm.name)*/{
  			if catchment_linked = catchm.name{
  				catchm.cell_of_the_catchment <- catchm.cell_of_the_catchment + self;
  			}
  		}
  		catchm.nb_cells <- length(catchm.cell_of_the_catchment);
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
   		if cycle < length(precipitation_per_step){
   			loop rain over: Lands_cells{  				
   				rain.precipitation_recieved<- (precipitation_per_step at cycle)/1000;// in m
   			}
   		}
   	}	
   }
   
   //infiltration part
   reflex infiltration{
   	if cycle < end_precipitation{
   		ask Land_Unit{
   			//check if the soil is saturated
   			if water_infiltrate != flat_infiltration_cell{
   				float diff_inf <- water_infiltrate + precipitation_recieved - flat_infiltration_cell;
   				if diff_inf <= 0.0{
   					water_infiltrate <- water_infiltrate + precipitation_recieved;
   					precipitation_recieved <- 0.0;
   				}
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
   
   //get the amount of water for impervious and pervious surface
   reflex get_flat_precipitation{
   	if cycle < end_precipitation{
   		ask catchment{
   			//calculation of the total volume that rain on the catchment
   			loop rain over: cell_of_the_catchment{
   				if rain.is_impervious = true{
   				runoff_volume_impervious <- runoff_volume_impervious + rain.precipitation_recieved;
   				}
   				else{
   				runoff_volume_pervious <- runoff_volume_pervious + rain.precipitation_recieved;
   				}
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
   		int nb_lag_time <- length(lag_time_stored where (each < time+step));
   		loop times: nb_lag_time{
   			volume_to_flow <- volume_to_flow + volume_stored at 0;
   			remove from: volume_stored index:0;
   			remove from: lag_time_stored index:0;
   		}
   	}
   }
   
   // Send the water from one catchment to another one
   reflex flow{
   	ask catchment sort_by each.ID{
   		put volume_to_flow in: hydro key: ID-1;
   		debit_volume_simulation <- debit_volume_simulation + [volume_to_flow/step];
   		
   		if volume_to_flow != 0.0{
   			if downstream = "out"{
   				volume_to_flow <- 0.0;
   			}
   			else{
   				float flow <- volume_to_flow;
   				volume_to_flow <- 0.0;
   				ask catchment where (each.ID=int(downstream)){
   					volume_stock <- volume_stock + flow;
   				}
   			}
   		 }
   	}
   }
   
   // a reflex to get some information
   reflex info{
   	global_volume <- 0.0;
   	  ask catchment{
   	  	total_volume <- 0.0;
   	  	loop total over:volume_stored{
   	  		total_volume <- total_volume + total;
   	  	}
   	  	total_volume_simulation <- total_volume_simulation + [total_volume];
   	  	global_volume <- global_volume + total_volume;
   	  }
   	  ask catchment sort_by each.ID{
   		put total_volume in: total_volume_global key: ID-1;
   	}
   }
   
   // a reflex for graphic output
   reflex graphic_output{
   	ask catchment{
   		do update_color;
   	}
   }
   
   // reflex to save the data into csv file
   reflex save_csv{
      if global_volume = 0.0 and cycle > end_precipitation{
   	     ask catchment{
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
	
	
	//graphic part
	rgb catch_color <- rgb(255,255,255);
	aspect catchments{
		draw shape color: catch_color;
	}
	
	//Update the color of the cell
      action update_color { 
         int val_water <- 0;
         val_water <- max([0, min([255, int(255*(total_volume/ (nb_cells*resolution^2)*20))])]) ;  
         catch_color <- rgb([255-val_water, 255-val_water, 255]);
      }
      
      //calculation of runoff lagtime
      action runoff_calculation{
      	// calculation of runoff for pervious surface
      	if runoff_volume_pervious != 0.0{
    		float Lag_time_runoff <- time + Lag_parameter_C * (resolution^2/1000^2*(nb_cells-nb_cells_impervious))^(0.57) * (runoff_volume_pervious/step)^(-0.23) * 3600;
    	    lag_time_stored <- lag_time_stored + Lag_time_runoff;
    	    lag_time_stored <- lag_time_stored sort_by (each);
    	    int localisation <- lag_time_stored index_of Lag_time_runoff;
    	    add item:runoff_volume_pervious to: volume_stored at: localisation;
    	    runoff_volume_pervious <- 0.0;
    	}
    	// calculation of runoff for impervious surface
      	if runoff_volume_impervious != 0.0{
    		float Lag_time_runoff <- time + Impervious_Lag_parameter * Lag_parameter_C * (resolution^2/1000^2*nb_cells_impervious)^(0.25) * 3600;
    	    lag_time_stored <- lag_time_stored + Lag_time_runoff;
    	    lag_time_stored <- lag_time_stored sort_by (each);
    	    int localisation <- lag_time_stored index_of Lag_time_runoff;
    	    add item:runoff_volume_impervious to: volume_stored at: localisation;
    	    runoff_volume_impervious <- 0.0;
    	}
      }
      
      action channel_calculation{
      	if volume_stock != 0.0{
    		float Lag_time_channel <- time + Stream_Lag_factor * 0.6 * Lag_parameter_C * (resolution*resolution/1000/1000*nb_cells)^(0.57) * (volume_stock/step)^(-0.23)*3600;
    	    lag_time_stored <- lag_time_stored + Lag_time_channel;
    	    lag_time_stored <- lag_time_stored sort_by (each);
    	    int localisation <- lag_time_stored index_of Lag_time_channel;
    	    add item:volume_stock to: volume_stored at: localisation;
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

experiment Nate type: gui {
	output {
		 display map_catchments type: opengl {
         species catchment aspect: catchments refresh: true;
         species rain_cell aspect: cells refresh: true;
      }
	}
}



experiment Run type: gui {
	
	parameter "duration of one step (in s)" var:step category:"global";
	parameter "distance of 1 side of Land_Unit (in m)" var:resolution category:"global";
	parameter "Lag parameter C" var:Lag_parameter_C category:"Lag parameters" min:1.3 max:1.8;
	parameter "Impervious Lag parameter" var:Impervious_Lag_parameter category:"Lag parameters" min:0.0 max:1.0;
	parameter "Stream Lag factor" var:Stream_Lag_factor category:"Lag parameters" min:0.0;
	parameter "The amount of water that can infiltrate (in m)" var:flat_infiltration_cell category:"Precipitation" min:0.0;
	parameter "The proportion of water that can infiltrate for pervious area" var:proportion_infiltration category:"Precipitation" min:0.0 max:1.0;
	
   output { 
   //layout vertical([0::5000,1::5000]) tabs:false editors: false;
      display map_cells type: opengl {
         species Land_Unit aspect: cells refresh: true;
      }
      display map_catchments type: opengl {
         species catchment aspect: catchments refresh: true;
         species rain_cell aspect: cells refresh: true;
      }
      
      display chart_display0 refresh:every(1 #cycles) { chart "catchment37" type: series { data "total volume" value: (total_volume_global at 36)  color: #green; } }
      display chart_display00 refresh:every(1 #cycles) { chart "catchment37" type: series { data "output volume" value: (hydro at 36)  color: #blue; } }
      display chart_display1 refresh:every(1 #cycles) { chart "catchment1" type: series { data "total volume" value: (total_volume_global at 1)  color: #green; } }
      display chart_display01 refresh:every(1 #cycles) { chart "catchment1" type: series { data "output volume" value: (hydro at 1)  color: #blue; } }
      display chart_display2 refresh:every(1 #cycles) { chart "catchment2" type: series { data "total volume" value: (total_volume_global at 2)  color: #green; } }
      display chart_display02 refresh:every(1 #cycles) { chart "catchment2" type: series { data "output volume" value: (hydro at 2)  color: #blue; } }
      display chart_display3 refresh:every(1 #cycles) { chart "catchment3" type: series { data "total volume" value: (total_volume_global at 3)  color: #green; } }
      display chart_display03 refresh:every(1 #cycles) { chart "catchment3" type: series { data "output volume" value: (hydro at 3)  color: #blue; } }
      display chart_display4 refresh:every(1 #cycles) { chart "catchment4" type: series { data "total volume" value: (total_volume_global at 4)  color: #green; } }
      display chart_display04 refresh:every(1 #cycles) { chart "catchment4" type: series { data "output volume" value: (hydro at 4)  color: #blue; } }
      display chart_display5 refresh:every(1 #cycles) { chart "catchment5" type: series { data "total volume" value: (total_volume_global at 5)  color: #green; } }
      display chart_display05 refresh:every(1 #cycles) { chart "catchment5" type: series { data "output volume" value: (hydro at 5)  color: #blue; } }
      display chart_display6 refresh:every(1 #cycles) { chart "catchment6" type: series { data "total volume" value: (total_volume_global at 6)  color: #green; } }
      display chart_display06 refresh:every(1 #cycles) { chart "catchment6" type: series { data "output volume" value: (hydro at 6)  color: #blue; } }
     
   }
}