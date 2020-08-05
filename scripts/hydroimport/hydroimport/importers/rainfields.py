from netCDF4 import Dataset
import datetime

def three(file, xbounds=None, ybounds=None):
    try:
        data = Dataset(file, "r", format="NETCDF4")
    except:
        return -1

    date = datetime.datetime.utcfromtimestamp(data.variables['valid_time'][0]*1)
    scaler = data.variables['precipitation'].scale_factor
    
    if (xbounds != None) and (ybounds != None):
        rain = data.variables['precipitation'][ybounds[0]:ybounds[1]+1, xbounds[0]:xbounds[1]+1].astype(float)*scaler*3600/300
    else:
        rain = data.variables['precipitation'][:].astype(float)*scaler*3600/300
    
    return rain, date