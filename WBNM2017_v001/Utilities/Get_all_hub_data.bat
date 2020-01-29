REM Batch file to download all data for a catchment from the ARR datahub
REM Inputs to the command line include the;
REM Longitude of te catchment CG
REM Latitude of the catchment CG.
REM Name of the catchment
REM 
REM Note must have python 3+ installed to run
REM      The catchment name is used to identify the downloaded txt file.
REM      The downloaded txt file is created in your current directory 
REM      
REM Edit the following to suit your file system and catchment details!

REM Current wbnm output drive
H:

REM Current wbnm output directory to contain the catchment hub data txt file 
cd  "H:\Projects\16001-01 wbnm 2017\sample_runfiles"

REM run the python script to download the required txt file
python  "Z:\Projects\2016\16001-01 wbnm 2017\wbnm2017\wbnm_py\wbnm_hubdl_all.py"  152.648  -29.573  "test_catchment"

pause