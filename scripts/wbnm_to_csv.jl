struct Rain_Gauge
    name::String
    latitude::Float64
    longitude::Float64
    precipitation::Array{Float16}
end

in_path = "Resources/WBNM2017_v001/WBNM 1998/190917_FCT_CS08a_STR02_August1998_RF11.wbn"
out_path = "data/rain/1998.csv"

file = open(in_path)
file_content = read(file, String)

precipitation_data = match(r"#####START_RECORDED_RAIN(?s).*#####END_RECORDED_RAIN", file_content).match

gauges = [x.match for x in eachmatch(r".*\n\s+\d{4,7}\.\d{2}\s+\d{4,7}\.\d{2}.*\n(?:.*\d{1,3}\.\d{2}\r\n)*", precipitation_data)]
num_gauge = length(gauges)

cells = Dict()
for gauge=1:num_gauge
    gauge_capture = gauges[gauge]
    name = match(r".*\n", gauge_capture).match
    latitude, longitude = [parse(Float64, x) for x in match(r"(?<latitude>\d{4,7}\.\d{2})\s+(?<longitude>\d{4,7}\.\d{2})", gauge_capture).captures]
    values = [parse(Float16, x.match) for x in eachmatch(r"\d{1,3}\.\d{2}", gauge_capture)]
    cells[gauge] = Rain_Gauge(name, latitude, longitude, values)
end