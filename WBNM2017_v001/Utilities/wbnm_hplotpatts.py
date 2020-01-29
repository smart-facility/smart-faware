'''
=======================================================
WBNM2017 Hyetograph  and Hydrograph Plot Script
=======================================================

wbnm_hplotpatts.py plots the outlet subareal hyeto/hydrographs
for the ensemble patterns as extracted from a wbnm meta file.
The IDs of the subareal events to plot are contained as a csv
list in an associated control file called 'yourcatchment'_hplotpatts.csv.
This csv and the  metafile should both be in the same directory
and this should be the current directory at the time the
script is run.

While wbnm_hplotpatts.py is similar to wbnm_hplotgen.py it is
specific to DES16 storm spectrum runs where plots of the outlet
hydrographs at the specified subarea for each pattern are required
as overliad outlet plots. The csv event format for wbnm_hplotpatts is;
eg 7-1.00-720-5(DES16),sub17
(storm 7, 1.00%AEP, crit 720min and crit 5 patt(DES16) on sub17)
The outlet hydrographs from each pattern atre overlaid on the one
Storm-AEP-Dura plot for each subarea include in the control csv.


this script is executed with the command
python ypurscriptpath\wbnm_hplotpatts.py yourcatchment_hplotpatts.csv

This script is coded in Intel PYTHON 3+
Version 001 E Rigby Dec2016
This code is FOS released under the GNU GPL3 licence

'''
import sys
import matplotlib.pyplot as plt

showplt = True  # turn plot display in browser on if True
saveplt = True  # turns saving plot as a png on if true
debug=False

# get the csv control file name from the name passed as an argument on the command line
control_plotfilename = sys.argv[1].rstrip(' ')

##### EXtract the name of the metafile and asscociated events to plot ##############
if (debug) : print('Reading control file %s into memory ' % control_plotfilename)
controlfile = open(control_plotfilename, 'r')
csvfile_lines = controlfile.readlines()
controlfile.close()
if (debug) : print('CSV control file read in referencing %i potential plots' % (len(csvfile_lines) - 1))
metafilename = csvfile_lines[0]
metafilename = metafilename.rstrip('\n')
####################################################################################


##### read in the specified wbnm meta file into memory #############################
print('Opening and reading metafile %s into memory - takes a while! ' % (metafilename))
infile = open(metafilename, 'r')
file_lines = infile.readlines()
infile.close()
if (debug) : print('Metafile read in is %d lines long' % (len(file_lines)))
if (debug) : print('Last line  is %s' % file_lines[len(file_lines) - 1])
if (len(csvfile_lines) > 20):
    print('Viewing of plots in browser has been forced off due to number of plots requested')
    showplt = False

###### loop through each requested critical DES16 event in the control csv file

for i in range(1, len(csvfile_lines)):
    #
    # reset vbles and lists prior to reading in a new DES16 critical event to ensemble plot
    time1 = []  # min
    time2 = []  # min
    time3 = []  # min
    time4 = []  # min
    time5 = []  # min
    time6 = []  # min
    time7 = []  # min
    time8 = []  # min
    time9 = []  # min
    time10 = []  # min
    tallpatts = []  # all times
    #
    qout1 = []  # outflow from outlet storage m3/sec in python patt=0
    qout2 = []  # outflow from outlet storage m3/sec in patt=1
    qout3 = []  # outflow from outlet storage m3/sec in patt=2
    qout4 = []  # outflow from outlet storage m3/sec in patt=3
    qout5 = []  # outflow from outlet storage m3/sec in patt=4
    qout6 = []  # outflow from outlet storage m3/sec in patt=5
    qout7 = []  # outflow from outlet storage m3/sec in patt=6
    qout8 = []  # outflow from outlet storage m3/sec in patt=7
    qout9 = []  # outflow from outlet storage m3/sec in patt=8
    qout10 = []  # outflow from outlet storage m3/sec in patt=8
    qallpatts = []  # all 1-10 patt hydrographs

    start_hydrograph_line = 0
    end_hydrograph_line = 0

    # check entry in control csv file is a DES16 event and if not skip read
    if (csvfile_lines[i].find('(DES16)') == -1):
        if (debug) : print('Skipping %s' % csvfile_lines[i])
        continue  # skip eventUID line altogether as not DES16 entry
    else:
        pass

    # Split the crit DES16 event csv  line into its two parts
    line_vals = csvfile_lines[i].split(',')

    # split the crit event details from the event csv line out of the UID
    crit_eventUID = line_vals[0]
    # split the event components out of the crit_eventUID
    UIDvals = crit_eventUID.split('-')
    stormID = str(UIDvals[0])  # as read in from csv control file
    aepval = str(UIDvals[1])
    duraval = str(UIDvals[2])  # assumes is DES16 crit dura for aep
    pattval = str(UIDvals[3]).replace('(DES16)','')  # assumes is DES16 crit patt no for crit dura and aep
    # save the subarea referenced in the control csv line
    subareaname = line_vals[1].rstrip('\n')
    start_subarea_string = 'START_HYDROGRAPHS_%s' % subareaname
    end_subarea_string = 'END_HYDROGRAPHS_%s' % subareaname

    ##### Got details for control csv event - start to build ensemble details

    # reset vbles and lists prior to starting a new DES16 ensemble plot
    time1 = []  # min
    time2 = []  # min
    time3 = []  # min
    time4 = []  # min
    time5 = []  # min
    time6 = []  # min
    time7 = []  # min
    time8 = []  # min
    time9 = []  # min
    time10 = []  # min
    tallpatts = []  # all times
    #
    qout1 = []  # outflow from outlet storage m3/sec in python patt=0
    qout2 = []  # outflow from outlet storage m3/sec in patt=1
    qout3 = []  # outflow from outlet storage m3/sec in patt=2
    qout4 = []  # outflow from outlet storage m3/sec in patt=3
    qout5 = []  # outflow from outlet storage m3/sec in patt=4
    qout6 = []  # outflow from outlet storage m3/sec in patt=5
    qout7 = []  # outflow from outlet storage m3/sec in patt=6
    qout8 = []  # outflow from outlet storage m3/sec in patt=7
    qout9 = []  # outflow from outlet storage m3/sec in patt=8
    qout10 = []  # outflow from outlet storage m3/sec in patt=8
    qallpatts = []  # all 1-10 patt hydrographs

    linetype = ["k-" for x in range(10)]
    linetype[0]="y-"  # Yellow solid
    linetype[1]="y--" # Yellow dash
    linetype[2]="b-"  # Blue solid
    linetype[3]="b--" # Blue dash
    linetype[4]="g-"  # Green solid
    linetype[5]="g--" # Green dash
    linetype[6]="m-"  # magenta solid
    linetype[7]="m--" # magenta dash
    linetype[8]="c-"  # cyan solid
    linetype[9]="c--" # cyan dash

    linewid = [1 for x in range(10)]     # pts thickness

    start_hydrograph_line = 0
    end_hydrograph_line = 0
    ensemble = True

    ##### loop to build the pattern specific event and to extract hydrograph for each pattern
    for patt in range(10):

        # build the ensemble event for the next ensemble pattern to obtain data for
        plotpatt = str(patt + 1) + '(DES16)'
        eventUID = stormID + '-' + aepval + '-' + duraval + '-' + plotpatt
        #
        ##### initialise found logic for this plot loop
        inblock = False  # have not found this events hydrograph block yet
        #
        ##### loop through meatfile to locate required hydrograph for this event pattern
        if (debug) : print('Looping through metafile for hydrograph for event %s at outlet of subarea %s ' % (eventUID, subareaname))
        for j in range(end_hydrograph_line, len(file_lines) - 1):  # read the meta file line by line starting at lineno
            #
            # if at the simulation line get the start of the event block and details on the following line
            if (file_lines[j].find('START_SIMULATION') > 0) and (file_lines[j].find(eventUID) > 0):
                # at start of specified  event block in metafile
                # print("Found start simulation line for event at metafile line", j)
                inblock = True
            #
            # found start event simulation line now find event hydrograph block
            elif (inblock) and (file_lines[j].find(start_subarea_string) > 0) and (file_lines[j].find(eventUID)) > 0:
                # at start of subarea hydrograph block for the specified event
                start_hydrograph_line = j
                #
            elif (inblock) and file_lines[j].find(end_subarea_string) > 0 and file_lines[j].find(eventUID) > 0:
                # at end of subarea hydrograph block for the specified event
                end_hydrograph_line = j
                break # done with reading metafile
                #
            else :
                pass
                #
        if (inblock != True):  # did not find event/pattern block at all in metafile - skip as not a DES16 ensemble run
            print('Could not find %s in %s so skipping this control file csv entry' % (eventUID, metafilename))
            ensemble = False
            break   # done with patt loop no such event patt hydrograph in metafile
        else:       # processing an ensemble pattern loop
            if (debug) : print('adding hydrograph for subarea %s in event %s  from meta %s' % (subareaname, eventUID, metafilename))
            # read in the event hydrograph at the specified subarea's outlet
            #
            #
            # read in and assign variables to plot for this storm-aep-dura-patt
            for hydrograph_line in file_lines[start_hydrograph_line + 2:end_hydrograph_line - 1]:
                rowvals = hydrograph_line.split()
                if (patt == 0):
                    time1.append(float(rowvals[0]))
                    qout1.append(float(rowvals[8]))
                elif (patt == 1):
                    time2.append(float(rowvals[0]))
                    qout2.append(float(rowvals[8]))
                elif (patt == 2):
                    time3.append(float(rowvals[0]))
                    qout3.append(float(rowvals[8]))
                elif (patt == 3):
                    time4.append(float(rowvals[0]))
                    qout4.append(float(rowvals[8]))
                elif (patt == 4):
                    time5.append(float(rowvals[0]))
                    qout5.append(float(rowvals[8]))
                elif (patt == 5):
                    time6.append(float(rowvals[0]))
                    qout6.append(float(rowvals[8]))
                elif (patt == 6):
                    time7.append(float(rowvals[0]))
                    qout7.append(float(rowvals[8]))
                elif (patt == 7):
                    time8.append(float(rowvals[0]))
                    qout8.append(float(rowvals[8]))
                elif (patt == 8):
                    time9.append(float(rowvals[0]))
                    qout9.append(float(rowvals[8]))
                elif (patt == 9):
                    time10.append(float(rowvals[0]))
                    qout10.append(float(rowvals[8]))
                #
            # reassign line type for this pattern if crit patt
            if (str(patt+1) == pattval ):  # assumes control pattern (pattval) was critical pattern
                linetype[patt] = "r-"  # set plot linestyle for ensemble crit plot to red
                linewid[patt] = 3
    if (ensemble):            # Have the ensemble data to plot
        # All pattern hydrographs for event found and saved  - calc axes limits for plot
        xmin = 0.0
        tallpatts = time1 + time2 + time3 + time4 + time5 + time6 + time7 + time8 + time9 + time10
        xmax = int(max(tallpatts) / 10.0 + 1.0) * 10
        hmin = 0.0
        qallpatts = qout1 + qout2 + qout3 + qout4 + qout5 + qout6 + qout7 + qout8 + qout9 + qout10
        hmax = int(max(qallpatts) / 10.0 + 1.0) * 10

        #
        # Build the overlaid hydrograph plot
        # set the style to use
        plt.style.use('ggplot')
        # Build the plot
        plt.figure(i + 1)

        plt.plot(time1, qout1, linetype[0], linewidth=linewid[0],label='Qout1')
        plt.plot(time2, qout2, linetype[1], linewidth=linewid[1],label='Qout2')
        plt.plot(time3, qout3, linetype[2], linewidth=linewid[2],label='Qout3')
        plt.plot(time4, qout4, linetype[3], linewidth=linewid[3],label='Qout4')
        plt.plot(time5, qout5, linetype[4], linewidth=linewid[4],label='Qout5')
        plt.plot(time6, qout6, linetype[5], linewidth=linewid[5],label='Qout6')
        plt.plot(time7, qout7, linetype[6], linewidth=linewid[6],label='Qout7')
        plt.plot(time8, qout8, linetype[7], linewidth=linewid[7],label='Qout8')
        plt.plot(time9, qout9, linetype[8], linewidth=linewid[8],label='Qout9')
        plt.plot(time10, qout10, linetype[9], linewidth=linewid[9],label='Qout10')

        plotname = crit_eventUID + ' (hypatts) on ' + subareaname + '.png'
        headerline = 'Ensemble Hydrographs crit event %s' % (plotname.replace('.png',''))
        plt.title(headerline)
        plt.xlim(xmin, xmax)
        plt.ylim(hmin, hmax)
        plt.xlabel('Time (min)')
        plt.ylabel('Discharge (m3/sec)')
        plt.legend()
        #
        #
        # optionally save each figure as a png
        if (saveplt):
            print('Saving plot :', plotname)
            plt.savefig(plotname)

# finally optionally display all plots created in a browser
if (showplt and ensemble):
    plt.show()
