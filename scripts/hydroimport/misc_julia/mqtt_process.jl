function grab_tag(string, tag)
    tag = match(Regex("\"$tag\":.*?(.*?),"), string)
    return tag.captures[1]
end

in_path = ARGS[1]
out_path = ARGS[2]

file_out = open(out_path, "w")

#data_dir = "data/mqtt"
data_dir = in_path
data_files = readdir(data_dir)

write(file_out, "latitude, longitude, distance, timestamp\n")

for file_name = data_files
    file_path = data_dir*"/"*file_name
    file = open(file_path, "r")
    file_content = read(file, String)
    lat = grab_tag(file_content, "latitude")
    lon = grab_tag(file_content, "longitude")
    lev = grab_tag(file_content, "distance")
    timestamp = grab_tag(file_content, "timestamp")
    write(file_out, "$lat, $lon, $lev, $timestamp\n")
end
close(file_out)