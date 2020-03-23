struct RainGauge
    name::String
    num::Int
    lat::Float64
    lon::Float64
    steps::Array{String}
    precip::Array{Float64}
end

in_path = ARGS[1]
out_path = ARGS[2]

file_out = open(out_path, "w")
data_files = readdir(in_path)

gauges = Dict()


for (index, file_name) in enumerate(data_files)
    file_path = in_path*"/"*file_name
    file = open(file_path, "r")
    file_content = read(file, String)
    data = eachmatch(r"(\d{2}/\d{2}/\d{4},\d{2}:\d{2}:\d{2}),(\d{1,4}.\d{1,4}),150", file_content)
    gauge_content = [parse(Float64, x.captures[2]) for x in data]
    timesteps = [x.captures[1] for x in data]
    station_name = match(r"Station Name, (.*)\r", file_content).captures[1]
    station_num = parse(Int, match(r"Station Number, (.*)\r", file_content).captures[1])
    latitude = parse(Float64, match(r"Latitude,(-?\d{1,4}.{1,9})", file_content).captures[1])
    longitude = parse(Float64, match(r"Longitude,(-?\d{1,4}.{1,9})", file_content).captures[1])
    gauges[index] = RainGauge(station_name, station_num, latitude, longitude, timesteps, gauge_content)
end

print(gauges[1].steps[1])