import sys, os
import numpy as np
import re, csv, datetime

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
        return [f"{inputs}/"+name for name in os.listdir(inputs) if ".csv" in name]

###LOAD FILES###
def load(inputs):
    data_for_ids = {}
    for file_name in inputs:
        file_in = open(file_name, "r")
        data = file_in.read()
        name = re.findall(r"Station Name, (?P<name>.*?)\n", data)[0]
        id = re.findall(r"Station Number, (?P<id>\d{4,7})\n", data)[0]
        lat = re.findall(r"Latitude,(?P<latitude>-?\d{0,7}.?\d{0,7})", data)[0]
        lon = re.findall(r"Longitude,(?P<latitude>-?\d{0,7}.?\d{0,7})", data)[0]
        values = re.findall(r"(?P<date>\d{1,2}/\d{1,2}/\d{4}),(?P<time>\d{1,2}:\d{1,2}:\d{1,2}),(?P<value>\d{0,3}.?\d{0,3})", data)
        data_for_dates = {}
        for value in values:
            time = datetime.datetime.strptime(value[0]+" "+value[1], "%d/%m/%Y %H:%M:%S")
            datum = value[2]
            data_for_dates[time] = datum
        data_for_ids[id] = {"metadata": {"latitude": lat, "longitude": lon, "name": name}, "data": data_for_dates}
    return data_for_ids

###WRITE LOADED DATA TO CSV###
def write_csv(data, output):
    ids = list(data.keys())
    file = open(output, "w")

    def write_metadata(file, data, ids):
        file.write("###START_METADATA###\n")
        parameters = list(data[ids[0]]["metadata"].keys())
        for param in parameters:
            file.write(param+",")
            for id in ids:
                file.write(str(data[id]["metadata"][param])+",")
            file.write("\n")

    def write_data(file, data, ids):
        file.write("###START_DATA###\n")
        dates = []
        for id in ids:
            dates.extend(list(data[id]["data"].keys()))
        dates = list(set(dates))
        dates.sort()
        for date in dates:
            file.write(date.strftime("%Y-%m-%d %H:%M")+",")
            for id in ids:
                try:
                    file.write(str(data[id]["data"][date])+",")
                except:
                    file.write(",")
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