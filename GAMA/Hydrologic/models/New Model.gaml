model GIS

species catchment {
	string type; 
    rgb color <- #gray  ;
    
    aspect base {
    draw shape color: color;
    }
}

global {
	file catchment_shape <- file("catchments.shp");
	//file dem_file <- file("C:/Users/nhutchis/Documents/Software/gama_workspace/Floodaware/models/shape/raster elevation/DEM_catchment_fairy_meadow_10m_resolution.tif");
	file rainfield <- file("rain.tif");
	//file precip <- file("rain2.tiff");
	file rain_csv <- file("rainfield_woll.csv");
	matrix rain_vals <- matrix(rain_csv);
	
	
	geometry shape <- envelope(rainfield);
	
	action init_rain {
		loop id from:0 to: rain_vals.rows -1{
  		ask rain{
  			// check if the name of rain cells the same that the one in the csv file
  			if int(rain_vals[2,id])= int(name){
  				//create a list with the rain information (is the amount of water that arrive during the step in mm)
  				loop lp from:0 to: rain_vals.columns-4{
  					precipitation_per_step <- precipitation_per_step + rain_vals[lp+3,id];
  				}
  			}
  		}
  		}
	}
	
	
	init {		
		loop cat over: catchment_shape{
      	create catchment from: [cat];
      	
      	do init_rain;
      	
    }
	}
	
  }

grid rain file: rainfield {
	list<float> precipitation_per_step;
}



experiment GIS type: gui {
	output {
		display catchments type: opengl {
			grid rain lines: #black;
			species catchment aspect: base;
		}
	}
}