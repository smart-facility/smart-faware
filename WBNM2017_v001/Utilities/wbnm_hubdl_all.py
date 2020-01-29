
import sys
import urllib.request


# Set user input paramaeters for catchment CG
cat_lon_coord = sys.argv[1].rstrip(' ')
cat_lat_coord = sys.argv[2].rstrip(' ')
cat_name = sys.argv[3].rstrip(' ')
print ('Extracting hub data for ',cat_name.strip, ' at lon of ',cat_lon_coord, ' & lat of ',cat_lat_coord)

try:
    # Alter the request  headers, to defined ourselves as a basic user
    # using a web browser - this avoids the ERROR 403  FORBIDDEN block.
    headers = {}
    headers['User-Agent'] = "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.27 Safari/537.17"
    # Then check print headers and rebuild the request string
    print(headers)
    request_string = ''.join(['http://data.arr-software.org/?lon_coord=',str(cat_lon_coord),'&lat_coord=',str(cat_lat_coord),'&All=on'])
    print(request_string)
    req = urllib.request.Request(request_string,headers=headers)
    # retrieve the page as a byte stream
    cat_data = urllib.request.urlopen(req)
    # read in the byte stream as str vals
    cat_data_text = str(cat_data.read())
    # replace the CR and Newline str with actual vals
    cat_data_text = cat_data_text.replace('\\n','\n')
    cat_data_text = cat_data_text.replace('\\r','\r')
    print (cat_data_text)
    savefile = open(cat_name + '_hub.txt', 'w')
    savefile.write(cat_data_text)
    savefile.close()



except Exception as ex:
    print(str(ex))
