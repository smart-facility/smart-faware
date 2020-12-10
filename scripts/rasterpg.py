#%%

import gdal
import re
import os

os.chdir("C:/users/nhutchis/OneDrive - University of Wollongong/Smart Waterways/Floodaware/data/rainfall/2020/ftp.bom.gov.au/2020/0203/")
files = [file for file in os.listdir() if (".nc" in file and ".nc." not in file)]

start_index = 0
interval = 500
done = False
os.environ['pgpassword'] = '1234'

while not done:
    next = start_index + interval
    if next > len(files) - 1:
        next = -1
        done = True
    for file in files[start_index:start_index+interval]:
        raster = gdal.Open(file)
        newname = re.findall(r'\d{8}_\d{4}', raster.GetDescription())[0]
        new_raster = gdal.Warp("c:/users/nhutchis/desktop/testout/{}.tif".format(newname), raster, outputType=gdal.GetDataTypeByName('Float32'))
        raster = None
        new_raster = None
    start_index = next
    os.system('cd c:/users/nhutchis/desktop/testout & raster2pgsql *.tif public.raster_temp -a -F | psql -U floodaware -d floodaware')
    removes = ['c:/users/nhutchis/desktop/testout/'+file for file in os.listdir('c:/users/nhutchis/desktop/testout/')]
    for file in removes:
        os.unlink(file)

# %%
