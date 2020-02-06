# smart-faware
## Floodaware Documentation
This repository is for the development of the Floodaware hydrological model for modelling of floods. This documents contains information to help understand the function of the model, as well as provides technical information about the implementation of the model.
### Hydrological Model
#### Overview
The GAMA model is split into three main parts:

1. Grid containing precipitation data over the Wollongong area
..* Data received from BOM
..* Python script used to preprocess files for use in GAMA

2. Raster layer containing cells to receive precipitation, calculate runoff etc
..* Cells either pervious or impervious
..* Pervious cells store an amount of water (5mm) before allowing for runoff
..* Different cells have different runoff characteristics

3. Catchment layer
..* Takes water output from connected raster layer cells
..* Performs lag calculations to send volumes of water to new catchments

#### Implementation
##### Preparation of Data
Data is extracted from BOM supplied netcdf files, and saved into a csv file. Either a whole directory of netcdf files can be selected, or a single file. If there are gaps larger than 10 minutes between netcdf files then the gaps are filled with zeros. A 7x7 grid is taken from the given 512x512 array of data, to only cover the catchments over the Wollongong area. For reference the coordinate pixels to extract are from x = 253 to 259, and y = 379 to 385, this was taken from a GIS projection of the BOM data over Wollongong. The grid information is saved from GIS software as a geotif to initialise the grid in GAMA. After extracting data from the files, the respective grid coordinates are flattened into a line, and stored in a csv file for import by GAMA.

##### Initialisation of Agents
Firstly catchment agents are initialised from the supplied shapefile, the catchment agents store the IDs of linked catchments downstream. The grid for land cell agents is initialised from a geotif raster of the elevation in the area. Elevation data is not presently used, this is just to provide a reference. Land cells overlapping catchments have the connected catchment stored. Any land cells not overlapping catchments are removed as they are unnecessary. The rain grid is initialised from the geotif, and cell precipitation values for each step grabbed from the csv file.

##### Running Model
Active rain cells with precipitation are set to update land cell water levels which overlap. When the rain that has fallen saturates the storage of pervious land cells, they begin to run off. Pervious land cells always absorb a proportional amount of the received precipitation, whereas impervious cells always give received rain as run off. After the volumes for the different runoff types are determined, the lag time must be then calculated for each of the runoff volumes. Once the lag time is calculated the volumes can be sent over the lag period to the downstream catchments. The runoff is split into three types: pervious, impervious, and channel. Channel runoff is the water that has flowed from upstream channels. For the runoff to move between catchments, water agents are created containing the amount of water, and the time when to deliver. When these agents are created the amount given to them is removed from giving catchment.

##### Visualisation and Graphing
The visualisation of the model consists of three layers, each showing its respective component of the model. The top layer shows movement of precipitation clouds, the second shows the infiltration of the ground in the land cells, finally the flow of water being shown below in hte catchment level.

Graphing currently consists of the total water flowing through the final catchment before going to sea. More graphing options can be added as necessary.