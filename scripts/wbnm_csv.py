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
        return [f"{inputs}/"+name for name in os.listdir(inputs) if ".wbn" in name]

###LOAD FILES###
def load(inputs):
    data_for_ids = {}
    for file_index, file_name in enumerate(inputs):
        file_in = open(file_name)
        data = file_in.read()
        gauges_section = re.findall(r"#####START_RECORDED_RAIN(?s).*#####END_RECORDED_RAIN", data)[0]
        date_string, num_gauge, mins, = re.findall(r"(\d{2}/\d{2}/\d{4})\n.*\n\s*(\d{1,4})\s*(\d{1,4}.?\d{1,4})\nMM/HR", gauges_section)[0]
        start_date = datetime.datetime.strptime(date_string, "%d/%m/%Y")
        mins = float(mins)
        num_gauge = int(num_gauge)
        gauges = re.findall(rf"(.*\n.*\d{{4,8}}.\d{{1,3}}  \d{{4,8}}.\d{{1,3}}\n(?:.*?\d{{1,4}}.\d{{2}}\n){{{num_gauge}}})", gauges_section)

        for gauge_index, gauge in enumerate(gauges):
            gauge = gauge.split("\n")
            gauge = [dat for dat in gauge if dat != ""]
            name = gauge[0]
            x, y = [coord for coord in gauge[1].split("  ") if coord != ""]
            x, y = float(x), float(y)
            data_points = gauge[2:]
            data_for_dates = {}
            current_date = start_date
            for point in data_points:
                data_for_dates[current_date] = float(point)*mins/60
                current_date = current_date + datetime.timedelta(minutes = mins)
            data_for_ids[str(file_index)+str(gauge_index+1)] = {"metadata": {"name": name, "x": x, "y": y}, "data": data_for_dates}
    
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