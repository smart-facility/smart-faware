REM Batch file to run wbnm_hplotpatts.py from a batch file
REM This produces overlaid ensemble plots for each subarea/storm
REM It assumes the dura is crit so the red ensemble hydrograph 
REM is crit for that storm aep on the associated subarea.
REM
REM 
REM Note must have python 3+ installed to run
REM      must have yourcatchment_meta.out in the current
REM      directory with your ?controlfile?.csv (can be called what you like).
REM      The csv from wbnm is called 'Yourcatchment'_hplotcrit.csv
REM      All plots will be saved to this (current) directory.
REM Edit the following to suit your file system and csv file name!

REM Current wbnm output drive
H:

REM Current wbnm output directory containing wbnm_hplotpatts.csv and meta
cd  "H:\Projects\16001-01 wbnm 2017\sample_runfiles"

REM run the python script to plot events/subs listed in csv control file to cd
python  "Z:\Projects\2016\16001-01 wbnm 2017\wbnm2017\wbnm_py\wbnm_hplotpatts.py"  SorellCk_testplt_hplotcrit.csv

pause