# %%
import gdal, pyproj
import datetime, re
from pg import DB
from pgdb import connect
import os
import matplotlib.pyplot as plt
import pickle

def pixel2coord(raster, x, y):
    xoff, a, b, yoff, d, e = raster.GetGeoTransform()

    xp = a * x + b * y + a * 0.5 + b * 0.5 + xoff
    yp = d * x + e * y + d * 0.5 + e * 0.5 + yoff
    return(xp, yp)



def init():
    id_base = 2e6
    db = DB(dbname='floodaware', host='localhost', port=5432, user='floodaware', passwd='1234')
    path = 'C:/Users/nhutchis/OneDrive - University of Wollongong/Smart Waterways/Floodaware/data/Rainfall/2020/ftp.bom.gov.au/2020/0203/'#+'3_20200331_234000.prcp-c5.nc'
    schema = ''
    index = 2e6
    format = 'rf3'

    if os.path.isfile(path):
        files = [path]
    elif os.path.isdir(path):
        files = [os.path.join(path, file) for file in os.listdir(path) if 'prcp-c5.nc' in file and '.nc.' not in file]
    
    return db, files, index, format

def buildInfo(files):
    points = []
    for file in files:
        raster = gdal.Open(file)
        inproj = raster.GetSpatialRef().ExportToProj4()
        outproj = pyproj.Proj('epsg:4326')
    
        totalCells = raster.RasterXSize*raster.RasterYSize

        for x in range(raster.RasterXSize):
            for y in range(raster.RasterYSize):
                x1, y1 = pixel2coord(raster, x, y)
                y2, x2 = pyproj.transform(inproj, outproj, x1, y1)

                currentIdx = x*raster.RasterXSize + y
                print("{}/{} -- {}%".format(currentIdx, totalCells, currentIdx*100/totalCells))
                points.append({"x": x, "y": y, "lat": y2, "lon": x2})

        return points

def uploadInfo(db, points, index, format):
    for point in points:
        x = point['x']
        y = point['y']
        lat = point['lat']
        lon = point['lon']
        id = str(int(index+x*1e3+y))
        name = 'X{:03}'.format(x)+'Y{:03}'.format(y)
        geom = 'POINT({} {})'.format(lon, lat)
        print(id, name, geom)
        parameters = {'id': id, 'name': name, 'type': format, 'geom': geom}
        db.query_formatted("INSERT INTO information (id, name, type, geom) VALUES (%(id)s, %(name)s, %(type)s, ST_GeomFromText(%(geom)s, 4326))", parameters)

#db, files, index, format = init()
#points = buildInfo([files[0]])
#pickle.dump(points, open('../radargridgis_pickle', 'wb'))
#uploadInfo(db, points, index, format)

def buildData(file, index):
    steps = []
    print(file)
    raster = gdal.Open(file)
    arr = raster.ReadAsArray()
    xrange = raster.RasterXSize
    yrange = raster.RasterYSize
    name = os.path.basename(file)
    timestamp = re.findall(r'\d{8}_\d{6}', name)[0]
    offset = float(raster.GetMetadata()['precipitation#scale_factor'])
    for x in range(xrange):
        for y in range(yrange):
            idx = str(int(index+x*1e3+y))
            val = arr[y, x] * offset
            #print(timestamp, idx, val)
            steps.append({"stamp": timestamp, "val": val, "id": idx})
    return steps

def uploadData(db, data):
    values = [(datum['stamp'], datum['val'], datum['id']) for datum in data]
    db.inserttable('rainfall', values)
        
db, files, index, format = init()
for file in files:
    data = buildData(file, index)
    #print([datum for datum in data if datum['val'] > 0])
    uploadData(db, data)

# %%
