#%%
import numpy as np
import gdal
import csv
import sys, os
import re
gdal.PushErrorHandler('CPLQuietErrorHandler')
'''add option to give filename or path to 
create csv file

create load function to be used in load folder, and by itself to minimise code
repeated

add in more functionality/capability to interpret timestamps, fill in data
between, split output to multiple csvs etc
'''
def fileOrDir(path):
    if os.path.isfile(path):
        return "file"
    elif os.path.isdir(path):
        return "dir"
    else:
        return "error"

def load_nc(file):
    print(file)
    if ".qpf-ens.nc" in file:
        try:
            dataset = gdal.Open(file, gdal.GA_ReadOnly)
            array_now = dataset.ReadAsArray()
        except:
            print("Error reading data")
            return "error"
        
        array_now = np.reshape(array_now, (10, 74, 512, 512))
        #cut array down to area covering wollongong
        array_now = array_now[:, :, 253:260, 379:386]#*0.05#*3600/(600/74)*0.05
        ''' This needs to be checked to make sure we're pushing the right units !!! '''
        return array_now
    else:
        print("##BIG WOOPSY##")
        return "not_netcdf"

def merge_folder(folder):
    master = []
    previous_time = 0
    for _, _, files in os.walk(folder):
        for name in files:
            nc_file = os.path.join(folder, name)
            #grab end timestamp for day from filename to calculate time between files
            #add empty array where files are missing
            current_time = int(re.search("(?<=_)....(?=...qpf)", name).group())
            length = current_time - previous_time
            if length > 10:
                master.append(np.empty((10, int(74*length/10 - 10), 7, 7)))
            array_now = load_nc(nc_file)
            if array_now != "error":
                master.append(array_now)
            previous_time = current_time
    master = np.concatenate(master, axis=1)
    return master

def write_csv(array, name):
    ensemble_member = 0
    csv_columns = ["Event code", "Start time", "Rain ID"]
    csv_columns = np.append(csv_columns, ["t"+str(num) for num in range(array.shape[1])])
    csv_data = []

    for y in range(array.shape[2]):
        for x in range(array.shape[3]):
            temp = {'t'+str(time):array[ensemble_member, time, y, x] for time in range(array.shape[1])}
            temp["Event code"] = "common"
            temp["Start time"] = "common"
            temp["Rain ID"] = x + y*array.shape[2]
            csv_data.append(temp)

    with open(name, 'w', newline='') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
        writer.writeheader()
        for data in csv_data:
            writer.writerow(data)

    
#%%
file_in = sys.argv[1]
file_out = sys.argv[2]
#%%
'''
root = os.path.realpath(__file__+"/../..")
sys.path.append(root)

file_in = os.path.join(root, "smart-faware/data/rain/rainfield_files/05")
file_out = os.path.join(root, "smart-faware/data/rain/test.csv")
'''
print(file_in)
print(file_out)

dir_file = fileOrDir(file_in)
print(dir_file)

if dir_file == "file":
    array = load_nc(file_in)
elif dir_file == "dir":
    array = merge_folder(file_in)
else:
    print("Error with filename")
    exit()

write_csv(array, file_out)
'''
name_in = "blahblah.nc"

root = os.path.realpath(__file__+"/../..")
sys.path.append(root)
folder_name = root+"/"+"data/rain/Rainfield_Files/05"
#array = load_nc(folder_name)
#write_csv(array)
'''
# %%dataset = gdal.Open(file, gdal.GA_ReadOnly)
