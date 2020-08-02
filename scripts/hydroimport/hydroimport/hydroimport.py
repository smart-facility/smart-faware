import sys, os
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
        'rf2': two
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
            print(rain.max())
            print(date)
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
        
        print(data)

def two():
        ###CONSTANTS###
        y_bound = (253,259)
        x_bound = (379,385)
        ensemble_member = 0

###PROGRAM FLOW HERE###
args = parser()
#print(args)
#look into determining type from files in folder etc
handler(args)