#!/bin/bash
#############################################################
#                                                           #
#    Shell script for test suite wbnm2017 on Ubuntu/linux   #
#                                                           #
#############################################################
cd /home/ted/
ls
cd /home/ted/wbnm2017_U/Sample_Runfiles/ 
ls -la
#
#
# REC Storms (short test)
/home/ted/wbnm2017_U/wbnm2017_U        Natural_RecdHG.wbn
/home/ted/wbnm2017_U/wbnm2017_U        Urban.wbn
/home/ted/wbnm2017_U/wbnm2017_U        Reservoir_routing.wbn
/home/ted/wbnm2017_U/wbnm2017_U        Onsite_detention.wbn
/home/ted/wbnm2017_U/wbnm2017_U        Culvert_h_q.wbn
#
#
#   REC Storms (full models)
/home/ted/wbnm2017_U/wbnm2017_U        Macriv_Jun9116.wbn
/home/ted/wbnm2017_U/wbnm2017_U        PRSC_FWS_Model_24_10_07.wbn
#
#
#   DES87 Storms (short test)
/home/ted/wbnm2017_U/wbnm2017_U       Design_external.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_partfull.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_hsq.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_blockage.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_dead.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_flow_divsns.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_inletcontrol.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_outlet_chnl.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_outlet_fixed.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_outlet_rating.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_scourable.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Storage_divert.wbn
/home/ted/wbnm2017_U/wbnm2017_U       WSUD_micro.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Offstream_storage.wbn
/home/ted/wbnm2017_U/wbnm2017_U       HED_onsite_detention.wbn
/home/ted/wbnm2017_U/wbnm2017_U       Road_embankment.wbn
#
#   DES87 Storms (full models)
/home/ted/wbnm2017_U/wbnm2017_U       Design_Spectrum87.wbn
#
#
#   EMB87  storms (short test)
/home/ted/wbnm2017_U/wbnm2017_U       Embedded_design.wbn
/home/ted/wbnm2017_U/wbnm2017_U       EMBdesign_external.wbn
#
#
#   EMB87  storms (full models)
/home/ted/wbnm2017_U/wbnm2017_U       Horsley_Design_2005_All_Clear.wbn
/home/ted/wbnm2017_U/wbnm2017_U       AllansCk_DES8716.wbn
#
#
#   DES16 storms (short tests)
/home/ted/wbnm2017_U/wbnm2017_U      DES16_Sample_Catch.wbn
#
#
#   DES16 storms (full models)
/home/ted/wbnm2017_U/wbnm2017_U      SorellCk_DES8716.wbn
/home/ted/wbnm2017_U/wbnm2017_U      Macriv_DES8716.wbn

