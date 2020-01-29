'''
=======================================================
WBNM2017 Hyetograph  and Hydrograph Plot Script
=======================================================

wbnm_hplotgen.py plots internal subareal hyeto/hydrographs
extracted from a wbnm meta file. The IDs of the subareal
events to plot are contained as a csv list in an associated
control file typically called 'yourcatchment'_hplotxxx.csv. This
csv and the  metafile should both be in the same directory
and this should be the current directory at the time the
script is run.

WBNM constructs a crit DES16 csv event control file if run with
out_critdes=.TRUE. This particular csv file contains a list
of events for each storm on each subarea restricted to
those events that were 'critical' if the storm is a design
spectrum run. Typical event entry format is;
eg 7-1.00-720-5(DES16),sub17
(storm 7, 1.00%AEP, 720min (critical)  and patt 5 (critical) for sub17)
The plot script however has no such limitation
and the user can build a list of any event on any subarea
desired that is in the meatfile and run that with wbnm_hplotgen.py.
eg 7-1.00-360-8(DES16),sub17
(storm 7, 1.00%AEP,  dura 360 and pattern 8 - not critical for sub17)

A REC event can be plotted by using its duration and assigning
'historic' to its AEP with pattern=1.
eg eg 3-historic-720-1(REC),sub17
A DES87 event can be similarly included by assigning pattern=1
egeg 2-100-720-5(DES87),sub17
(Noting that the ARI for a DES87 event is an integer eg 100yr ARI)

this script is executed with the command
python ypurscriptpath\wbnm_hplotgen.py yourcatchment_hplotgen.csv

This script is coded in Intel PYTHON 3+
Version 001 E Rigby Dec2016
This code is FOS released under the GNU GPL3 licence

'''
import sys
import matplotlib.pyplot as plt

showplt = True  # turn plot display in browser on if True
saveplt = True  # turns saving plot as a png on if true
debug = False

# get the csv control file name from the name passed as an argument on the command line
control_plotfilename = sys.argv[1].rstrip(' ')

##### EXtract the name of the metafile and asscociated events to plot ##############
if (debug) : print('Reading control file %s into memory ' % control_plotfilename)
controlfile = open(control_plotfilename, 'r')
csvfile_lines = controlfile.readlines()
controlfile.close()
if (debug) : print('CSV control file read in referencing %i plots' % (len(csvfile_lines) - 1))
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
if (len(csvfile_lines) > 21):
    print('Viewing of plots in browser has been forced off due to number of plots involved')
    showplt = False

###### loop through each plot requested
for i in range(1, len(csvfile_lines)):
    #
    line_vals = csvfile_lines[i].split(',')
    eventUID = line_vals[0]
    UIDvals = eventUID.split('-')
    stormID = str(UIDvals[0])  # as read in from csv control file
    aepval = str(UIDvals[1])  # storm aep for simulation
    duraval = str(UIDvals[2])  # assumes is DES16 crit dura for aep
    pattval = str(UIDvals[3]).replace('(DES16)', '')  # assumes is DES16 crit patt no for crit dura and aep
    # save the subarea referenced in the control csv line
    subareaname = line_vals[1].rstrip('\n')
    start_subarea_string = 'START_HYDROGRAPHS_%s' % subareaname
    end_subarea_string = 'END_HYDROGRAPHS_%s' % subareaname
    #
    ##### initialise parameters for this plot loop
    inblock = False
    start_hydrograph_line = 0
    end_hydrograph_line = 0
    #
    ##### loop through meatfile to locate required hydrograph
    if (debug) : print('Looping through metafile to locate hydrograph for event %s at outlet of subarea %s ' % (eventUID, subareaname))
    for j in range(len(file_lines) - 1):  # read the meta file line by line starting at lineno
        #
        # if at the simulation line get the start of the event block and details on the following line
        if (file_lines[j].find('START_SIMULATION') > 0) and (file_lines[j].find(eventUID) > 0):
            # at start of specified  event block in metafile
            # print("Found start simulation line for event at metafile line", j)
            inblock = True
            start_event_line = j
            continue
        else:
            pass
        #
        #
        if (inblock) and (file_lines[j].find(start_subarea_string) > 0) and (file_lines[j].find(eventUID)) > 0:
            # at start of subarea hydrograph block for the specified event
            start_hydrograph_line = j
            # print("Found start simulation line for subarea at metafile line", j)
            continue
            #
        if (inblock) and file_lines[j].find(end_subarea_string) > 0 and file_lines[j].find(eventUID) > 0:
            # at end of subarea hydrograph block for the specified event
            end_hydrograph_line = j
            # print("Found end simulation line for subarea at metafile line", j)
            break  # exit for read loop - got what we want.
            #
    if (inblock != True):  # did not find event block al all - raise error
        print('Could not find %s in %s' % (eventUID, metafilename))
        continue # go to next event in read loop
        #
    if (debug) : print('Plotting hydrograph for subarea %s in event %s  from meta %s' % (subareaname, eventUID, metafilename))
    # read in the event hydrograph at the specified subarea's outlet
    #
    time = []  # min
    rain = []  # mm/hr
    qtop = []  # inflow into top of sub m3/sec
    qbot = []  # flow rate at bottom of stream pre storage m3/sec
    qper = []  # runoff from pervious are of sub m3/sec
    qimp = []  # runoff from impervious are of sub m3/sec
    qintoos = []  # inflow into outlet storage m3/sec
    qoutos = []  # outflow from outlet storage m3/sec
    #
    # read in and assign variables to plot
    for hydrograph_line in file_lines[start_hydrograph_line + 2:end_hydrograph_line - 1]:
        # print (hydrograph_line)
        rowvals = hydrograph_line.split()
        # print(rowvals)
        time.append(float(rowvals[0]))
        rain.append(float(rowvals[1]))
        qtop.append(float(rowvals[3]))
        qbot.append(float(rowvals[4]))
        qper.append(float(rowvals[5]))
        qimp.append(float(rowvals[6]))
        qintoos.append(float(rowvals[7]))
        qoutos.append(float(rowvals[8]))
        #
    # calc axes limits for plot
    xmin = 0.0
    xmax = int(max(time) / 10.0 + 1.0) * 10
    hmin = 0.0
    hmax = int(max(qintoos) / 10.0 + 1.0) * 10
    rmin = 0.0
    rmax = int(max(rain) / 10.0 + 1.0) * 10
    #
    # Build the hydrograph plot
    # set the style to use
    plt.style.use('ggplot')
    # Build the plot
    plt.figure(i + 1)
    plt.subplot2grid((4, 1), (1, 0), rowspan=3)
    plt.plot(time, qoutos, 'k-', label='Qout_OS')
    plt.plot(time, qintoos, 'k--', label='Qinto_OS')
    plt.plot(time, qimp, 'r-', label='Qimp')
    plt.plot(time, qper, 'm--', label='Qper')
    plt.plot(time, qbot, 'g-', label='Qbot')
    plt.plot(time, qtop, 'g--', label='Qtop')
    plt.xlim(xmin, xmax)
    plt.ylim(hmin, hmax)
    plt.xlabel('Time (min)')
    plt.ylabel('Discharge (m3/sec)')
    plt.legend()
    #
    plt.subplot2grid((4, 1), (0, 0))  # plot in the top plot grid space
    headerline = 'Subarea Hyeto/Hydrographs for event %s on %s' % (eventUID, subareaname)
    plt.title(headerline)
    plt.fill_between(x=time, y1=rain, y2=0, step='mid')
    plt.xlim(xmin, xmax)
    plt.ylim(rmin, rmax)
    plt.ylabel('Rain (mm/hr)')
    #
    # optionally save each figure as a png
    if (saveplt):
        plotname = eventUID + ' (int_hy) on ' + subareaname + '.png'
        print('Saving plot :', plotname)
        plt.savefig(plotname)
# finally optionally display all plots in a browser
if (showplt):
    plt.show()
