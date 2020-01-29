********WBNM2017********
********November 2017*******

This release contains  the latest version of the flood hydrograph model WBNM. 
WBNM hasw been subject to continuing research and development since 1994. 
This present release contains a major update of the existing hydrology simulation engine 
and its various input and processing routines. 
All of the functionality of the 2012 release is retained with the additional ability to 
use the ARR 2016 Design Flood Esimation procedure for design storms.


To assist users to install and use the model the software contains :

EXECTIBLES  subfolderfolder :
=====================

WBNM2017_w64.EXE   - main program to operate WBNM software in a 64 bit Windows environment
WBNM2017_w32.EXE   - main program to operate WBNM software in a 32 bit Windows environment
WBNM2017_U               - main program to operate WBNM software in a 64/32 bit Linux/Ubuntu environment
GLOBAL.INI                   - Typical global parameter initialisation file

 


DOCUMENTATION sub-folder
==========================================

WBNM_Readme.txt                               - this file
WBNM_ExperiencedUser_update.docx - Basic instruction on operation of wbnm2017  

WBNM_History.pdf         - document giving the history of WBNM version releases 
WBNM_References.pdf - document listing all papers referred to in WBNM_Theory.doc
WBNM_Runfile.pdf         - document giving the structure of the runfile
WBNM_Theory.pdf         - document giving the theory and assumptions in the model
WBNM_Tutorial.pdf        - document explaining results from the sample *.wbn files
WBNM_UserGuide.pdf   - document giving background details of the model
WBNM_Validation.pdf     - document describing recorded and simulated hydrographs for natural 
                                         and urban catchments, ranging from very large to very small.

WBNM2017Structure,pdf - graphic outlining relationship between WBNM2017 code blocks and calls 

PUBLICATIONS sub-folder
==========================================
WBNM_Publications      - list of published papers relating to wbnm



SAMPLE RUNFILES sub-folder 
===========================================
REC Storms (short tests)
  Natural_RecdHG.wbn      		- sample runfile for a natural catchment with recorded storm
  Urban.wbn			- runfile for part urban catchment with recorded storm
  Reservoir_routing.wbn		- file which lets you use WBNM for flood routing of an inflow
                                                                  hydrograph through a storage reservoir
  Onsite_detention.wbn      		- small onsite detention storage calculations
  Culvert_h_q.wbn			- file which lets you use WBNM to calculate culvert hydraulics

REC Storms (full models)
  MacRiv_Jun9116.wbn       		- file representing a very complex catchment with storages/Xflows
  PRSC_FWS_Model_24_10_07.wbn	- file representing a very large and complex catchment 

DES87 Storms (short tests)
   Design_external.wbn		- An ARR 1987embedded design storm, with design rainfall IFD coefficients
                                  		  located in an external IFD file rather than in the runfile
   Storage_partfull.wbn		- storage reservoir part full at start of storm
   Storage_hsq.wbn			- a repeat of STORAGE_INLETCONTROL.WBN, but using an entered
                                                                  table of elevation-storage-discharge values, rather than 
                                                                  specifying culvert dimensions
   Storage_blockage.wbn		- a storage with one of the outlets blocked by debris
   Storage_dead.wbn		- storage reservoir that must fill to specified elevation before outflowing
   Storage_flow_divsns.wbn		- structure that diverts flows to multiple downstream points (m3/s)
   Storage_inletcontrol.wbn		- runfile for storage reservoir with culvert inlet control
   Storage_outlet_chnl.wbn		- storage reservoir with culvert outlet control, tailwater set
                                                                  by trapezoidal downstream channel
   Storage_outlet_fixed.wbn		- storage reservoir with culvert outlet control, fixed tailwater level
   Storage_outlet_rating.wbn		- storage reservoir with culvert outlet control, tailwater set
                                                                   by rating curve in downstream channel
   Storage_scourable.wbn		- storage reservoir with erodible spillway
   Storage_divert.wbn		- storage that diverts flows that exceed a nominated discharge (m3/s)
   WSUD_micro.wbn		- example of Water Sensitive Urban Design at the micro scale
   Offstream_storage.wbn		- a storage located offstream, but directly connected to the stream channel
   HED_Onsite_detention.wbn	- onsite detention using a High Early Discharge outlet
   Road_Embankment.wbn		- models flow over a road embankment with a dip

DES87 Storms (full models)
  Design_Spectrum87.wbn		- example of a DES87 storm spectrum runfile

EMB87  storms (short tests)
   Embedded_design.wbn		- demonstrating a design burst embedded within a longer design storm even
   EMBdesign_external.wbn		- the same embedded design storm, but with design rainfall IFD coefficients
                                                                  located in an external IFD file rather than in the runfile

EMB87  storms (full models)
   Horsley_Design_2005_All_Clear.wbn - example of an embeded design ARR 1987 storm on a real catchment

DES16 storms (short tests)
  DES16_Sample_Catch.wbn		- Example of an ARR 2016 design storm on a simple catchment

DES16/DES87  storms (full models)
   AllansCk_Test.wbn		- Full real catchment model with ARR87 and ARR16 design storms
  SorellCk_Test.wbn		- Full real catchment model with ARR87 and ARR16 design storms
  Macriv_Test.wbn			- Full real catchment model with ARR87 and ARR16 design storms

#################################################################################################



####################################################################################

Release History:

#####Version 1.06 Initial Beta release

#####Version 1.07 Changes:
1) slight change to WBNMdetails.doc and Readme.txt
2) An error in some Summary tables and debug flag corrected

#####Version 1.08 (November 1999) Changes:
1) Output from run, debug messages, and the runfile echo, now go to Windows as the
   program is run. Text in these these windows can be scrolled
2) Some anomalies in screen output when debug and echo flags were set have been corrected
3) The end point of results written to the output files can be specified by setting the
   value of trig_flowmin_percent in either the global.ini or project.ini files. The default
   is 5%
4) Iterative calculations have been extended, so that volume balances in the Volume
   Summary table are now specified with more accuracy
5) WBNM can be run in batch mode - see WBNM Background and User Guidelines.doc for
   details
6) *.doc and *.txt documents given more meaningful filenames
7) WBNM Background and User Guidelines.doc expanded
8) In previous versions, for culverts with outlet control, the elevation of the downstream 
   channel was set at the invert of the culvert outlet. However, when several culverts at
   different elevations are used, the particular elevation of the channel bed must be 
   specified. Version 1.08 now does this. Note that an extra data item, the elevation of the
   downstream channel bed, is required in the runfile. Version 1.08 contains amended *.wbn
   runfiles.
9) Expanded to allow 150 subareas and 15 rain gauges.

#####Version 1.09 (January 2000) Changes:

1) For easier interpretation of runfiles, culvert/ weir types are changed from
   B TO #####BOX, P to #####PIPE, W to #####WEIR and F TO #####FUSE.
   Similarly, stream channel routing options are changed from
   R to #####ROUTING, D to #####DELAY and M to #####MUSK.
   You will have to change these values in your runfiles.
2) The volume summary table is expanded to include the volume of any hydrograph imported
   into the top of a subarea, and also any hydrographs directed to the bottom of a subarea.
3) You now have more control over where you direct the outflows from storage reservoirs/ 
   detention basins. For each outlet (eg culvert or weir), you can nominate whether the flow 
   goes to the #####TOP or the #####BOTTOM of the nominated downstream subarea.   
4) Programs WBNMCONV and WBNMCHCK are now windows compatible.


#####Version 2.01 (April 2000) Changes:
1) Runfile and User Guide documents added to.
2) WBNMCONV takes the name of the old runfile and converts it to WBNM2000 format, and
   appends the extension .wbn onto the old runfile name.
3) Slight addditions to WBNMCHCK program.
4) More details of onsite detention storage, including high early discharge OSD in 
   User Guide, plus 2 sample runfiles



#####Version 3.00 (November 2000)
This upgrade has many major enhancements. It will require some changes to your current
runfiles. See the sample runfiles *.wbn for examples, and see WBNM2000_Runfile.doc for 
the runfile layout. We have also included 2 files to help you indentify the necessary
changes. These are V300file and V201file.

1) Allows 200 subareas, 25 rain gauges, 2592 calculation steps (9 days at 5 minutes)

2) We have renamed the output meta file Runfile_Meta.out (ie it takes your runfile name
   Runfile.wbn, strips of the extension wbn, and appends _Meta.out. To create a meta file,
   set out_metafile =.TRUE.

3) With every run, a QA file Runfile_QA.out is automatically produced, which contains 
   summary tables (depending on which sum_*** flags are set to true), plus the hyetographs and
   hydrographs from the outlet subarea. You might want to set out_metafile =.FALSE.
   and avoid the voluminous output in that file. Use Runfile_QA.out for most purposes, and 
   Runfile_Meta.out for detailed hydrographs from all subareas, and for plotting graphs.

4) Detailed culvert calculations are now written to Runfile_Culv.out (previously this was
   WBNMCULV.OUT).

5) Detailed scouring weir results are now written to Runfile_Scour.out (previously this was
   WBNMFUSE.OUT).

6) Local Structures have been given the same capabilities as Outlet Structures (with 2
   exceptions - see user guide).

7) Local Structures now allow the storage to be part full at the start of the storm.

NOTE: you must now enter a value of INITIAL_WATER_LEVEL_IN_STORAGE immediately
after the Elevation-Storage table in the local structures block.

8) Local structures now allow outlet control in culverts as well as inlet control. They also
   allow scouring weirs.

9) Runfile data must now be given in field widths of 12. The program WBNMFRMT.EXE will take
   your old runfiles and format them correctly.

10) The design rainfall coefficients must now be formatted in field widths of 12. Runfile.doc
    gives details of this. The external file containing design IFD rainfall data must also
    be formatted in this way. See WBNM.IFD for an example.

11) The order of design rainfall coefficients has been changed to group PMP values together. 
    The %ROUGH now occurs next to the MOISTURE ADJUSTMENT FACTOR. See WBNM2000_Runfile.doc
    or any of the example *.wbn files with design rainfall.

12) The runfile now allows (and requires) you to add a descriptor for each outlet structure,
    for each local structure, and for each storm. 

NOTE: You must add these descriptors, as shown in WBNM2000_Runfile.doc. You must
also add as the first and last lines for each storm #####START_STORM#1 and #####END_STORM#1;
as the first and last lines for each local structure #####START_LOCAL_STRUCTURE#1 and
#####END_LOCAL_STRUCTURE#1; and as the first and last lines for each outlet structure
#####START_OUTLET_STRUCTURE#1 and #####END_OUTLET_STRUCTURE#1.

13) The Outlet Structure and Local Structure outlet hydraulics for culverts have been
    changed from #####H_S, #####H_S_Q, #####OUTLET_CONTROL etc to:

#####H_S_Q - elvation-discharge relation entered as a table of values
#####H_S - elevation-discharge calculated from culvert hydraulics assuming inlet control applies
#####H_S(TWF) - elevation-discharge relation calc from culvert hydraulics checking both inlet
                & outlet control, with fixed tailwater elevation in the downstream channel
#####H_S(TWR) - elevation-discharge relation calc from culvert hydraulics checking both inlet
                & outlet control, with tailwater elevation in the downstream channel set by
                a rating table
#####H_S(TWC) - elevation-discharge relation calc from culvert hydraulics checking both inlet
                & outlet control, with tailwater elevation in the downstream channel set by
                Manning's equation for the downstream channel cross-section

13) Program WBNMSORT will take your runfile & check that the subareas are in the correct
    sequence. If not, it will re-sort them.

14) The documentation has been split into several smaller WORD documents to allow
    easier reference. The best one to get started is WBNM_UserGuide.doc.

15) WBNM_Runfile.doc has been colour coded and simplified for easier understanding.
 
16) Correction to PMP calculations for duration < 60 minutes

17) WBNM_Runfile.doc amended for Local Structure details

###################################################################################

##### WBNM2001 Version 1.00 (June 2001)

1) Note that when directing flows from Outlet Structures to downstream subareas, you must
   nominate whether the flow goes to the TOP or BOTTOM of the subarea. Do not specify 
   #####TOP or #####BOTTOM as stated in the previous version.

2) Outflows from Outlet strucures (ie through culverts and weirs) can be directed to up 
   to 10 downstream locations.

3) At outlet structures, the maximum water level was previously given. Now the complete
   stage hydrograph is given (written to the QA and Meta output files). See User Guide.

4) You can now apply storage factors to the storage volumes for flood routing in Local
   Structures and in Outlet Structures. If you specify a storage factor of zero, all 
   storage volumes in the structure are set to zero, and the hydrograph passes through the
   structure without any flood routing ie the inflow and outflow hydrographs are identical.

5) You can now apply discharge factors to the culvert and weir discharges for flood routing
   in Local Structures and in Outlet Structures. These can be used for partial or full culvert
   blockages by debris.

6) Calculation of tailwater levels in the downstream channel (for culverts with outlet
   control) has been improved. See WBNM_Theory.doc for details

7) More details on High Early Discharge onsite detention storage calculations
   (see WBNM_Theory.doc).

8) A sample runfile WSUD_micro.wbn is included to demonstrate modelling of Water Sensitive
   Urban Design in catchments.
  

9) Now allows multiple runs of up to 20 storms.

10) You can now enter recorded hydrographs as a Discharge Hydrograph or as a Stage Hydrograph, 
   and WBNM2001 will convert. Up to 10 recorded hydrographs can be used. See User Guide.

11) You can now enter imported hydrographs as a Discharge Hydrograph or as a Stage Hydrograph, 
   and WBNM2001 will convert. Up to 10 imported hydrographs can be used. See User Guide.

12) Imported hydrographs and recorded hydrographs can occur at the TOP or the BOTTOM of subareas.

13) Hydrographs written to output files can be cut off either when flows drop below specified
    values, or when a specified cut-off time is exceeded.

14) The storm block of the runfile has been modified to include these new features.
   Essentially, all data entries for a particular operation are included
   within START and END blocks. We also have new blocks for the rating tables.
   See WBNM_Runfile.doc for the runfile structure.

15) Additional coordinates allow catchment schematic to overlay map & raster displays.

16) New front end runfile editor and program controller.
    See WBNM_FrontEnd.doc

17) New plotting graphics. See WBNM_View.doc

18) Since the runfile structure for this version is changed from previous versions, you must
    specify the version number in the STATUS block of the runfile. Currently this is
    2001_V100    WBNM checks the version number and warns you if your runfile is not compatable.


For users of WBNM2000 version 3.00, several changes must be made to the runfile structure.
See Super.wbn for an example, and WBNM_Runfile.doc. In summary :

a) Line 4 of the STATUS block must have the version number 2002_V100

b) The DISPLAY block needs additional top right E and N map coordinates for to allow 
   rotation of map images.

c) Every outlet (culvert, weir) must have a discharge factor (0-1) to model blockage.

d) Every basin must have a storage factor (0-1).

e) All culvert/ weir details are contained within #####START_OUTLET_DETAILS and 
   #####END_OUTLET_DETAILS tags.

f) Storm data are contained within #####START_RECORDED_RAIN, #####START_DESIGN_RAIN,
   #####START_EMBEDDED_DESIGN_RAIN. and the corresponding #####END tags.

g) Raingauge weights are contained within #####START_INPUT_RAINGAUGE_WEIGHTS, 
   #####START_CALC_RAINGAUGE_WEIGHTS, and the corresponding END tags.

h) Rainfall losses are contained within #####START_LOSS_RATES, #####START_RUNOFF_PROPORTIONS
   and the corresponding END tags.

i) Rainfall units are now MM/HOUR or MM/PERIOD, not #####MM/HOUR, #####MM/PERIOD.

j) Design rainfall coefficients are now IFD_COEFFS_IN_THIS_FILE or IFD_COEFFS_IN_IFD_FILE, 
   not #####IFD_COEFFS_IN_THIS_FILE or #####IFD_COEFFS_IN_IFD_FILE.

k) Imported hydrographs and recorded hydrographs are contained within #####START_IMPORTED_HYDROGRAPHS
   #####START_RECORDED_HYDROGRAPHS, and the corresponding END tags.

l) Each imported or recorded hydrograph is contained within #####START_RECORDED_HYDROGRAPH#1,
   #####END_RECORDED_HYDROGRAPH#1 (and similar for imported).

m) Imported and recorded hydrographs can be at the TOP or BOTTOM of the subarea.

n) The subarea name is the first item in each recorded and imported hydrograph block.

o) Imported and recorded hydrographs can be DISCHARGE or STAGE. If STAGE, a rating table is
   needed to convert to discharge. It will be contained within #####START_RATING_TABLE and 
   #####END-RATING_TABLE tags.

###################################################################################

##### WBNM2002 Version 100 (January 2002) GRAPHICS VERSION

This is an extension of WBNM2001, with minor changes to the runfile structure. The
calculation engine is essentially unchanged from WBNM2001.
The major additions are the GUI front end for overall operation of the model, and for 
runfile creation/editing, and the back end graphics.

Minor changes to the runfile from V2001 to V2002 are :

1) For both local strucures and outlet structures, with #####H_S_Q type structures, each 
   outlet is in a block headed by #####HSQ. This is equivalent to #####BOX, #####PIPE etc
   for #####H_S etc type structures, and makes the entries for all strucure types (#####H_S, 
   #####H_S(TWF), #####H_S_Q etc) the same.

2) For local structures, with #####H_S_Q type structures, each outlet block has a delay time
   for flows from the local structure to reach the subcatchment outlet.

These runfile structures are shown in WBNM_Runfile.doc and in the example runfile Super.wbn

Runfiles must have the version number in the STATUS block of the runfile. Currently this is
2002_V100 WBNM checks the version number and warns you if your runfile is not compatible.

NOTE : This release does not have WBNMMAIN, the front end to control running of the
software and a WINDOWS template to create runfiles. This will be added in the next 
month or so. For now, you can run all programs directly, ie WBNMRUN is the 
calculation engine, and WBNMVIEW is he graphics viewer. When running WBNMRUN, select the 
*.wbn runfile from the Sample Runfiles Folder. When this has been done and the metafile created 
(by WBNMRUN), run WBNMVIEW and select the meta file to open. For example, if you use 
NATURAL.WBN with WBNMRUN, the metafile NATURAL_META.OUT is automatically created. You will
select NATURAL_META.OUT when you run WBNMVIEW.

NOTE : For ease of use of the viewer (WBNMVIEW), coordinates of subcatchments & rain gauges
should be in metres rather than km. If km are used, you can scale the schematic down to a 
viewable size (see WBNM_VIEWGUIDE.pdf). 

###################################################################################

#####WBNM2002 Version 100A (May 2002) GRAPHICS VERSION

This release is the same as V1.00 January 2002, but has the GUI front end WBNMMAIN added.
You can now edit runfiles using a text editor, or use the GUI to create new rundfiles and
edit existing runfiles. This is a first release of the GUI, if you detect any bugs, please 
email Ted Rigby or Michael Boyd.

NOTE : All pdf files included as documentation in this release MUST be placed in a sub-
folder of the WBNM root folder, and the sub-folder must be named Documentation.

After installation, to run WBNM2002, start WBNMMAIN, then open your selected runfile
from the Sample Runfiles folder. When viewing graphical output, select the meta.out 
extension to your runfile from the Sample Runfiles folder.

####################################################################################

##### WBNM2002 Version 101 (June 2002) 

1) Includes correction of minor bugs in the beta release of editor of WBNMMAIN.

2) WBNMCHCK checking program now lists total number of warnings & errors at END of screen
output.

3) Copying of graphics plots to clipboard for pasting into documents is now more intuitive
and consistent with WINDOWS printing commands.

4) A file WBNM_Validation.pdf, showing selected calculated and recorded hydrographs is
included in the documentation.

5) Includes links to CatchmentSIM, a GIS tool which creates a DEM of the catchment, draws
the stream network & defines catchment & subcatchment boundaries. Subcatchment properties, 
such as the area (in hectares) are automatically measured. CatchmentSIM then automatically
creates a runfile for use in WBNM. See the WBNM web page at 
http://www.uow.edu.au/eng/research/wbnm.html 

Note that there may still be some minor bugs remaining in the editor of WBNMMAIN, as this 
is a new addition to the software.

####################################################################################

##### WBNM2003 Version 100 (March 2003)

1) Output to meta & QA files now to 3 decimal places for modelling small urban sites and
onsite detention storage

2) Error in Horton infiltration fixed

3) Flood routing in Local Structures & Outlet Structures, already comprehensive & robust,
has been improved. Now extra points are automatically added to the Elevation-Storage 
relation, corresponding to the elevation of all culverts/weirs (See WBNM_Theory.pdf for 
details).

4) Can now run 210 storms, allowing analysis of the full specrtrum of design storms, from 
1 to 500 year ARI and up to the PMP storm, and storm durations from 5 minutes to 72 hours.
A summary of results is obtained by setting the flag sum_multistorms to TRUE. This writes 
voluminous output to the meta file and to the screen. You can deactivate these by setting 
the out_metafile and debug_echo flags to FALSE

5) Setting the flag trig_flowmin to a negative value (eg -100) writes hydrographs to 100
time steps.

6) User defined design storm temporal patterns can be entered as a percent of the total
   storm depth (see WBNM_Theory.pdf).

NOTE: this release has only a minor change to the runfile structure from the previous version 
2002 101, when using PERCENT storm temporal patterns. (See WBNM_Runfile.pdf)


####################################################################################

##### WBNM2003 Version 101 (August 2003)

This release contains a few minor fixes to version 100. There is no change to
the runfile structure from version 100. Changes are :

1) Time varying rainfall losses option previously set excess rainfall to 
   zero, now fixed.

2) Elevation-discharge relation for Local Structures (HSQ type) was previously
   written as zero in metafile, although the correct values were used in calculations. 
   Correct discharge values now written to Metafile.

3) WBNMview did not show plots when a catchment was modelled with only 1 subarea.
   Now corrected.

4) Save As for files in main editor did not update the file pathname. Now corrected.

####################################################################################

##### WBNM2003 Version 102 (December 2003)

This release contains a few minor fixes to version 101. There is no change to
the runfile structure from version 101. Changes are :

1) Longer filename & pathname lengths are allowed (be up to 1024 characters).
2) Minor changes to application (*.exe) programs, which do not affect input or results
   - mainly to make more robust.

Runfiles from the previous version 101 can be used with this version.
####################################################################################

##### WBNM2003 Version 103 (June 2005)

This release contains a few minor fixes to version 102. There is no change to
the runfile structure from version 102. Changes are :

1) Starting time for scour of scourable weirs can be specified.
2) Probable Maximum Precipitation storms are invoked using ARI = 9999.
3) Documents, especially Wbnm_Theory.pdf have been revised.

Runfiles from the previous version 102 can be used with this version.
####################################################################################

##### WBNM Version 104 (January 2007)

1) Minor bug in WBNMCHCK - D/S channel Manning's n gave incorrect error message 
   - this did not affect calculations.
2) Local Structures which delayed the discharge hydrograph by a specified time, did not delay 
   the corresponding Stage hydrograph. This is now corrected.
3) Stage-discharge writes to metafile & QA output files for HSQ type multiple outlets
   in Local Structures wrote zero values for each outlet's discharge. Now corrected. 
   - this did not affect program calculations.
4) Outlet & Local structures, when initial water level was above the storage bottom elevation,
   did not divert flowrates at time zero to appropriate downstream locations. Now fixed.

5) Format for writes to screen, meta & QA files modified to allow for very large, as well
   as very small volumes, covering very large to very small catchment sizes.

6) Flood routing in Outlet and Local structures may give oscillations near the peak, 
   if a weir causes sudden increases in discharges and the peak water level is near to the  
   weir elevation. WBNM now gives a warning if the outflow peak exceeds the inflow peak
   (by more than 2%), and suggests use of a smaller calculation time step. 

7) Baseflow hydrographs can be added - see discussion in WBNM_Theory.pdf 

8) Road embankments with a dip in the road elevation can be modelled as sets of horizontal 
   broad crested weirs. See discussion in WBNM_Theory.pdf and sample runfile Road_embankment.wbn.

9) Offstream storages can be modelled. See discussion in WBNM_Theory.pdf, WBNM_Tutorial.pdf, plus 
   sample runfiles Offstream_storage.wbn, Offstream_storage_1.wbn

10) Outlet Structures and Local Structures - time when blockage occurs can be specified, or 
    culverts can be blocked when the peak rainfall intensity occurs. See WBNM_Theory.pdf and 
    sample runfile Storage_blockage.wbn.

11) iWBNM added in this release. iWBNM is an Excel worksheet which can be used as an interface 
    for WBNM. It allows fast and simple construction of runfiles, allows checking of runfiles, 
    and analysis of WBNM results. iWBNM is a powerful add-on, and Users are recommended to try it.
    The iWBNM Excel worksheet should be placed in the main WBNM folder, along with WBNMRun and 
    other exe programs.
    NOTE: iWBNM needs Microsoft Office 2003 version of Excel to run.

####################################################################################

##### WBNM2007_VLA Version 1.00(June 2007)  (Limited Release)

1)  Very Large Array version to accomodate large models eg 2000 subareas & Structures

####################################################################################

##### WBNM2009 Version 1.00(November 2009) (Limited Release)

1)  First version using adjustable arrays for main arrays - some arrays still fixed

####################################################################################


##### WBNM2010 Version 1.00(February 2010) (Limited Release)

1) All arrays now dynamic 



####################################################################################

##### WBNM2012 Version 1.00(June 2012) (FINAL FORMAL RELEASE)

1)   General tidy up for source release under GNU GPL_v3 licence
2)   Checks added to new dynamic array code
3)   Old wbnm_GUI retired as limited to quite small array models
4)   wbnm-chk, wbnm_fmt, and wbnm_srt incresed to 1000 subareas but still fixed
5)   All docs upgraded to reflect changes since 2007

####################################################################################


####################################################################################

##### WBNM2017 Version 1.00(Nov 2017) (PUBLIC RELEASE)

1)   Furtherl tidy up sources - now Fortran 2003/8 compliant  
2)   Partial optimisation of simulation code
3)   Windows dialog boxes deleted - all GUI code removed - no external libraries
4)   All output files now optional via ini settings
5)   Spectrum capability added to ARR 1987 design storms (ex storm type DES87)
6)   optional calculation of IL/CL losses as subarea specific or GLOBAL
7)   ARR 2016 Ensemble storm procedure for DFE added (new storm type DES16)
8)   Ability to read downloaded ARR16 Datahub catchment data, including losses and storm patterns
9)   Ability to read and apply BOM 2017 IFD data from multi station database file
10) Optional calculation of DES16 duration and pattern storm or spectrums
11) Optional calulation  of DES16 ARF as fixed or ARR16 value for catchment
12) Optional calculation of DES16  IL/CL losses  as subarea specific, GLOBAL or computed as per ARR 2016
13) New storm-catchment  summary table reflecting different outputs from REC DES87 DES16 storms
14) Additional arrays and new critical dura/pattern tables and file to reflect storm spectrum results (DES87 and 16)
15) Format of some output files changed to limit impact of spectrums on file sizes
16) Additional debug outputs to dbg_log file reporting on additional functionality 
17) Additional runfiles added to samples, demonstrating new functionality
16)  All docs upgraded to reflect changes since 2012

####################################################################################

##### Disclaimer ###################################################################

This computer software and the accompanying documentation has been written to transfer research carried out 
by the developers and other researchers, in flooding and stormwater management, to the engineering profession. 
The combination of academic researchers and engineering practicioners in its development makes WBNM ideally 
suited for use in the engineering office. While we have taken considerable care in the development of the software and 
accompanying documentation making up the WBNM Software Package, the software and the accompanying 
documentation should not be used as the sole source of information for flood studies. 
Reference should also be made to Australian Rainfall and Runoff, textbooks and other published material on hydrologic modelling.
We have provided sample runfiles and full details of the model to help you understand how WBNM works. 
The onus is on you as the user to carefully determine whether your application of WBNM is correct, and to carefully review 
results to verify that they are sensible. 

The developers and their respective organisations make no warranty of any kind in connection with this Software Package.
 The developers and their respective organisations shall not be liable for any errors contained in the Software Package 
nor for any incidental or consequential damages resulting from the furnishing or use of the Software Package. 
The developers and their respective organisations are not engaging in providing engineering services in furnishing the 
Software Package. Users of the Software Package are advised that output from the Software Package should be 
subjected to independent checks. The developers and their respective organisations reserve the right to revise and 
otherwise change the Software Package from time to time . 

WBNM provides extensive output , both to the screen and to output files, allowing detailed checking of results.
 This information should be carefully reviewed by the user to confirm the validity of the results.

Users should read carefully the documentation provided with the WBNM software.



