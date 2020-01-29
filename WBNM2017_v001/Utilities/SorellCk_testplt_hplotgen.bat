REM Batch file to run wbnm_hplotgen.py from a batch file
REM This plots all subareal hyeto and hydrographs for all
REM events-subareas  listed in the control csv file.
REM
REM Note must have python 3+ installed to run
REM         must have yourcatchment_meta.out in the current
REM         directory with your ?controlfilename?.csv. 
REM         All plots will be saved to this (current) directory.
REM Edit the following to suit your file system and csv control file name!

REM Current wbnm output drive
H:

REM Current wbnm output directory containing wbnm_hplot.csv and meta
cd  "H:\Projects\16001-01 wbnm 2017\sample_runfiles"

REM run the python script to plot events/subs listed in csv control file to cd
python  "Z:\Projects\2016\16001-01 wbnm 2017\wbnm2017\wbnm_py\wbnm_hplotgen.py"  SorellCk_testplt_hplotcrit.csv

pause