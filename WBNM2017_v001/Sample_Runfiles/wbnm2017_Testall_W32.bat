REM   ++++++++++++++++++++ WBNM2017_v001  W32 TEST SUITE ++++++++++++++++++++++++++++
echo on

REM If you wish to use on your system you will need to edit the current directory path and the path of the wbnm2017 exe file!!!
REM It is strongly recommended that you  turn the metafile and debug log file off in your project.ini before running this bat file.
REM (Otherwise the script will run very slowly and create a great many very large files)

Z:

cd "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_repository\WBNM2017_v001\Sample_runfiles"

REM REC Storms (short test)
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        Natural2012.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        NaturalUsingCatchmentName.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        NaturalUsingGlobalLosses.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        NaturalUsingGlobalLags.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        Urban2012.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        Reservoir_routing.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        Onsite_detention.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        Culvert_h_q.wbn



REM REC Storms (full models)
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        MacRiv_Jun91.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"        PRSC_FWS_Model_24_10_07.wbn


REM DES87 Storms (short test)
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Design_external.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_partfull.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_hsq.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_blockage.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_dead.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_flow_divsns.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_inletcontrol.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_outlet_chnl.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_outlet_fixed.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_outlet_rating.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_scourable.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Storage_divert.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       WSUD_micro.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Offstream_storage.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       HED_Onsite_detention.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Road_Embankment.wbn


REM DES87 Storms (full models)
"Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Design_Spectrum87.wbn


REM EMB87  storms (short test)
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Embedded_design.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       EMBdesign_external.wbn


REM EMB87  storms (full models)
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       Horsley_Design_2005_All_Clear.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"       AllansCk_Test.wbn


REM DES16 storms (short tests)
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"      DES16_Sample_Catch.wbn

REM DES16 storms (full models)
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"      SorellCk_Test.wbn
 "Z:\projects\2016\16001-01 wbnm 2017\wbnm2017\Local_Repository\WBNM2017_v001\Executables\WBNM2017_W32.exe"      Macriv_Test.wbn


pause