model playground

global {
	file rain_data <- file("../../../data/rain/gauges.csv");
	
	init {
		write matrix(rain_data) row_at 0;
	}
}



experiment Visualise type: gui {

}