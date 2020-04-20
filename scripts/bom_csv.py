import sys, os
import numpy as np
import re, csv, datetime
from netCDF4 import Dataset

###CONSTANTS###
y_bound = (253,260)
x_bound = (379,386)
ensemble_member = 0

def fileOrDir(path):
    if os.path.isfile(path):
        return "file"
    elif os.path.isdir(path):
        return "dir"
    return "error"

###PARSER FOR COMMAND LINE ARGUMENTS###
def parse():
    inputs = sys.argv[1]
    outputs = sys.argv[2]
    return {"inputs": inputs, "outputs": outputs}

###INITIALISE PROGRAM BY CHECKING INPUT ARGUMENTS###
def init(inputs):
    in_type = fileOrDir(inputs)
    if in_type == "file":
        return [inputs]
    else:
        return [f"{inputs}/"+name for name in os.listdir(inputs) if ".qpf-ens.nc" in name]

###LOAD FILES FROM INIT###
def load(inputs):
    data_for_dates = {}
    for file in inputs:
        try:
            data = Dataset(file, "r", format="NETCDF4")
        except:
            continue
        timesteps = data.variables["valid_time"][:]
        dates = [datetime.datetime.utcfromtimestamp(step) for step in timesteps]
        for index, date in enumerate(dates):
            data_for_dates[date] = data.variables["precipitation"][0,index, y_bound[0]:y_bound[1], x_bound[0]:x_bound[1]]
    
    data_for_ids = {}
    dates = data_for_dates.keys()
    for y in range(y_bound[1]-y_bound[0]):
        for x in range(x_bound[1]-x_bound[0]):
            id = x+y*(x_bound[1]-x_bound[0])
            data_for_ids[id] = {"metadata": {"latitude": "nil", "longitude": "nil"}, "data": {date:data_for_dates[date][x,y] for date in dates}}

    return data_for_ids

def write_csv(data, output):
    ids = list(data.keys())
    file = open(output, "w")

    def write_metadata(file, data, ids):
        file.write("###START_METADATA###\n")
        parameters = list(data[0]["metadata"].keys())
        for param in parameters:
            file.write(param+",")
            for id in ids:
                file.write(str(data[id]["metadata"][param])+",")
            file.write("\n")

    def write_data(file, data, ids):
        file.write("###START_DATA###\n")
        dates = list(data[0]["data"].keys())
        for date in dates:
            file.write(date.strftime("%Y-%m-%d %H:%M")+",")
            for id in ids:
                file.write(str(data[id]["data"][date])+",")
            file.write("\n")
    
    file.write("id,")
    for id in ids:
        file.write(str(id)+",")
    file.write("\n")

    write_metadata(file, data, ids)
    write_data(file, data, ids)

args = parse()
files = init(args["inputs"])
data = load(files)
write_csv(data, args["outputs"])