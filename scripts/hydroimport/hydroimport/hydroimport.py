import sys, os, re, datetime
import importers.rainfields as rainfields

def fileOrDir(path):
    if os.path.isfile(path):
        return "file"
    elif os.path.isdir(path):
        return "dir"
    return "error"

###PARSER FOR COMMAND LINE ARGUMENTS###
def parser():
    args = sys.argv[1:]
    tags = {'i': 'input', 'o': 'output', 't': 'type'}
    results = {'input': None, 'output': None, 'type': None}
    for tag in tags.keys():
        if "-"+tag in args:
            idx = args.index("-"+tag)
            result = args[idx+1]
            results[tags[tag]] = result.strip('"')
        elif "--"+tags[tag] in args:
            idx = args.index("--"+tags[tag])
            result = args[idx+1]
            results[tags[tag]] = result.strip('"')
    #sort out positional arguments
    print(args)
    return results

###PROGRAM HANDLER###
def handler(args):
    def errorChecker(args):
        if (args['input'] == None or args['output'] == None or args['type'] == None):
            return -1
    
    if errorChecker(args) == -1:
        return -1

    switch = {
        'rf3': three,
        'rf2': two,
        'mhl': mhl
    }

    switch[args['type']]()

###IMPORTER HANDLERS###
def three():
        ###CONSTANTS###
        y_bound = (281,292)
        x_bound = (250,262)
        ###############
        
        in_path = args['input']
        in_type = fileOrDir(in_path)

        if in_type == 'file':
            files = [in_path]
        elif in_type == 'dir':
            files = [f"{in_path}/"+name for name in os.listdir(in_path) if (".prcp-c5.nc" in name) and (".nc." not in name)]
        
        data_dates = {}

        for file in files:
            print(file)
            rain, date = rainfields.three(file, x_bound, y_bound)
            #print(rain.max())
            #print(date)
            data_dates[date] = rain


        data_ids = {}
        dates = data_dates.keys()
        for x in range(x_bound[1]-x_bound[0]):
            for y in range(y_bound[1]-y_bound[0]):
                id = x*(x_bound[1]-x_bound[0])+y
                data_ids[id] = {
                    'metadata': {'latitude': 'nil', 'longitude': 'nil'},
                    'data': {date:data_dates[date][x,y] for date in dates}
                }
        print(args['output'])
        write_csv(data_ids, args['output'])

def two():
        ###CONSTANTS###
        y_bound = (253,259)
        x_bound = (379,385)
        ensemble_member = 0

def mhl():
    in_path = args['input']
    in_type = fileOrDir(in_path)

    if in_type == 'file':
        files = [in_path]
    elif in_type == 'dir':
        files = [f"{in_path}/"+name for name in os.listdir(in_path) if ".csv" in name]

    data_for_ids = {}
    for file_name in files:
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

    print(args['output'])
    #print(list(data_for_ids.keys()))
    write_csv(data_for_ids, args['output'])

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
        dates = list(data[ids[0]]["data"].keys())
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

###PROGRAM FLOW HERE###
args = parser()
#print(args)
#look into determining type from files in folder etc
handler(args)