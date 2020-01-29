'''
=======================================================
WBNM2017 Ensemble Hydrograph Box Plot Script
=======================================================

wbnm_hplotbox.py constructs a box plot of the ensemble pattern 
hydrographs for a DES16 spectrum storm event and locations 
listed in  a control csv file, using data recorded in the 
associated wbnm meta file. The IDs of the subareal
events to include are contained as a csv list in an associated
control file typically called 'yourcatchment'_hplotpatts.csv. 
This csv and the  metafile should both be in the same directory
and this should be the current directory at the time the
script is run.

While wbnm_hplotbox.py is similar to wbnm_hplotpatts.py in that it is
specific to DES16 storm spectrum runs. It provides box plots of the the 
average peak outlet flow for each pattern and duration.
The csv event format for wbnm_hplotbox is, as for Hyplotpatts;
eg 7-1.00-720-5(DES16),sub17
(storm 7, 1.00%AEP, crit dura 720min and a crit pattern number of 5 with discharge from sub17)



this script is executed with the command
python ypurscriptpath\wbnm_hplotbox.py yourcatchment_hplotbox.csv

This script is coded in Intel PYTHON 3+
Version 001 E Rigby Dec2016
This code is FOS released under the GNU GPL3 licence

'''

##### import reqd modules
import sys
import matplotlib.pyplot as plt

##### set initial parameters
debug = False
showplt = True  # turn plot display in browser on if True
saveplt = True  # turns saving plot as a png on if true
NstdARR16durations = 20
NstdARR16patterns = 10

##### Get the csv control file name from the name passed as an argument on the command line
control_plotfilename = sys.argv[1].rstrip(' ')

##### EXtract the name of the metafile and asscociated events to plot ##############
if (debug) : print('Reading control file %s into memory ' % control_plotfilename)
controlfile = open(control_plotfilename, 'r')
csvfile_lines = controlfile.readlines()
controlfile.close()
if (debug) : print('CSV control file read in referencing %i potential plots' % (len(csvfile_lines) - 1))
metafilename = csvfile_lines[0]
metafilename = metafilename.rstrip('\n')

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

###### loop through each listed critical DES16 event in the control csv file and plot associated boxplot

for i in range(1, len(csvfile_lines)):
    #
    ##### reset event vbles and lists prior to reading in a new DES16 critical event to ensemble plot
    Qpevent = []
    start_hydrograph_line = 0
    end_hydrograph_line = 0

    ###### check entry in control csv file is a DES16 event and if not skip read
    if (csvfile_lines[i].find('(DES16)') == -1):
        if (debug) : print('Skipping %s not a DES16 storm simulation' % csvfile_lines[i])
        continue  # skip eventUID line altogether as not DES16 entry
    else:
        pass

    ##### Split the crit DES16 event csv  line into its two parts and decode vals
    line_vals = csvfile_lines[i].split(',')
    crit_eventUID = line_vals[0]
    # split the event components out of the crit_eventUID
    UIDvals = crit_eventUID.split('-')
    stormID = str(UIDvals[0])  # as read in from csv control file
    aepval = str(UIDvals[1])  # storm aep for simulation
    duraval = str(UIDvals[2])  # assumes is DES16 crit dura for aep
    pattval = str(UIDvals[3]).replace('(DES16)', '')  # assumes is DES16 crit patt no for crit dura and aep
    # save the subarea referenced in the control csv line
    subareaname = line_vals[1].rstrip('\n')
    start_subarea_string = 'START_HYDROGRAPHS_%s' % subareaname
    end_subarea_string = 'END_HYDROGRAPHS_%s' % subareaname

    ##### Got details for control csv event - start to build event details

    ##### Reset vbles and lists prior to extracting data for this DES16 event

    stdARR16duras = [10,15,30,60,120,180,360,720,1440,2880,4320,5760,7200,8640,10080]
    stdARR16patts = [ 1,2,3,4,5,6,7,8,9,10]

    start_hydrograph_line = 0
    end_hydrograph_line = 0

    spectrum = True # initially assume is a DES16 spectrum run with all duras and patts in metafile

    ##### loop to build the aep-dura-pattern specific event and to extract hydrograph max for the event
    #
    Qpduras = [] # initialise pattern Qps for all duras

    for dura in range(len(stdARR16duras)):
        #
        if(spectrum != True) :
            break

        Qppatts = [] # initialise Qps for the current dura
        for patt in range(len(stdARR16patts)):
            if(spectrum != True) : # Last patt not in metafile - probably a specific des16 event storm
                # skip this patt and via other breaks the current csv file entry
                break
            ##### build the  event details for the next event dura/patt event to obtain data for
            des16dura = stdARR16duras[dura] # dura in minutes
            des16duraID = str(des16dura)
            des16patt  = patt
            des16pattID = str(patt+1) + '(DES16)'
            eventUID = stormID + '-' + aepval + '-' + des16duraID + '-' + des16pattID
            #
            ##### initialise found logic for this event loop
            inblock = False  # have not found this events hydrograph block yet
            #
            ##### loop through meatfile to locate required hydrograph for this event pattern
            if (debug): print('Looping through metafile for event %s at outlet of subarea %s ' % (eventUID, subareaname))
            for j in range(end_hydrograph_line, len(file_lines) - 1):  # read the meta file line by line
                #
                # if at the simulation line get the start of the event block and details on the following line
                if (file_lines[j].find('START_SIMULATION') > 0) and (file_lines[j].find(eventUID) > 0):
                    # at start of specified  event block in metafile
                    if (debug) :  print("Found start simulation line for event at metafile line", j)
                    inblock = True
                #
                # found start event simulation line now find event hydrograph block
                elif (inblock) and (file_lines[j].find(start_subarea_string) > 0) and (
                        file_lines[j].find(eventUID)) > 0:
                    # at start of subarea hydrograph block for the specified event
                    start_hydrograph_line = j
                    #
                elif (inblock) and file_lines[j].find(end_subarea_string) > 0 and file_lines[j].find(eventUID) > 0:
                    # at end of subarea hydrograph block for the specified event
                    end_hydrograph_line = j
                    break  # done with reading metafile got star and end line nos
                    #
                else:
                    pass
                    #
            # either found hydrograph data for this event in meta or read mwta and no event present

            if (inblock != True):  # did not find event/pattern block at all in metafile - skip not DES16 spectrum run
                if (debug) : print('Could not find %s in %s so skipping this control file csv entry' % (eventUID, metafilename))
                spectrum = False
                break  # done with this loop no such event aep/dura/patt hydrograph in metafile
            else:  # processing a simulated spectrum event
                if (debug) : print('Found hydrograph for subarea %s in event %s  from meta %s' % (subareaname, eventUID, metafilename))

                # read in and assign variables to plot for this storm-aep-dura-patt event
                Qpout = []
                for hydrograph_line in file_lines[start_hydrograph_line + 2:end_hydrograph_line - 1]:
                    rowvals = hydrograph_line.split()
                    Qpout.append(float(rowvals[8]))
                Qpmaxevent = max(Qpout)
                Qppatts.append(Qpmaxevent)

        # done reading event data for the  patt loop
        Qpduras.append(Qppatts)
    # done reading event data for the dura loop
    if (spectrum != True) : # skip plot for this csv entry iand read next
        continue
    else :
        pass
    # Build the box plot for the Qps for each dura
    print('plotting Qps for each pattern and dura in box plot format for ', crit_eventUID , ' on ',subareaname)
    # set the style to use
    plt.style.use('ggplot')
    # Build the plot
    dmin = 0
    dmax = len(stdARR16duras)+1
    qmin = 0
    Qpdurasmax=0.0
    qmaxpatts=[]
    for x in range(len(stdARR16duras)) :
        if (Qpdurasmax <=  max(Qpduras[x])):
            Qpdurasmax = max(Qpduras[x])
        qmaxpatts.append(int(Qpdurasmax)+1)
    qmax = max(qmaxpatts)

    plt.figure(i) # one for each entry in the control csv file

    plt.boxplot(Qpduras,whis='range',showmeans=True,labels=stdARR16duras)
    stormname = stormID +'-'+aepval+'-(DES16) (boxplts) on ' + subareaname
    plotname = stormname  + '.png'
    headerline = 'Qp pattern boxplots for %s' % (stormname)
    plt.labels = stdARR16duras
    plt.title(headerline)
    plt.xlim(dmin, dmax)
    plt.ylim(qmin, qmax)
    plt.xlabel('DES16 Event Std Duration (min)')
    plt.ylabel('Pattern Peak Discharge (m3/sec)')
    #
    #
    # optionally save each figure as a png
    if (saveplt):
        if (debug) : print('Saving plot :', plotname)
        plt.savefig(plotname)

# finally optionally display all plots created in a browser
if (showplt):
    plt.show()
