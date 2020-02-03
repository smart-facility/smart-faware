#%%
import numpy as np
import gdal
import csv
import sys, os
import re

root = os.path.realpath(__file__+"/../..")
sys.path.append(root)
folder_name = root+"/"+"data/rain/Rainfield_Files/05"

def load_nc(folder):
    master = []
    previous_time = 0
    for _, _, files in os.walk(folder):
        for name in files:
            print(name)
            if ".qpf-ens.nc" in name:
                nc_file = os.path.join(folder,name)
                try:
                    dataset = gdal.Open(nc_file, gdal.GA_ReadOnly)
                    array_now = dataset.ReadAsArray()
                except:
                    print("Error reading data")
                    continue
                current_time = int(re.search("(?<=_)....(?=...qpf)", name).group())
                length = current_time - previous_time
                if length > 10:
                    master.append(np.empty((10, int(74*length/10), 7, 7)))
                array_now = np.reshape(array_now, (10, 74, 512, 512))
                array_now = array_now[:, :, 253:260, 379:386]*0.05
                master.append(array_now)
                previous_time = current_time
    master = np.concatenate(master, axis=1)
    return master

def write_csv(array):
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

    with open(root+"/data/gong_csv.csv", 'w', newline='') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=csv_columns)
        writer.writeheader()
        for data in csv_data:
            writer.writerow(data)
    
#%%
array = load_nc(folder_name)
write_csv(array)