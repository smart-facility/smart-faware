struct rain_cell
    latitude::Float64
    longitude::Float64
    precipitation::Array{Float64}
end

in_path = "Resources/WBNM2017_v001/WBNM 1998/190917_FCT_CS08a_STR02_August1998_RF11.wbn"
out_path = "data/rain/1998.csv"

file = open(in_path)
file_content = read(file, String)

precipitation_data = match(r"#####START_RECORDED_RAIN(?s).*#####END_RECORDED_RAIN", file_content).match

num_gauge = parse(Int, match(r"(\d+).*\n.*\n.*[0-9]{5,6}\.[0-9]{2}.*?[0-9]{5,6}\.[0-9]{2}", precipitation_data).captures[1])

num_steps = parse(Int, match(r".*\n.*\n.*\n.*?(\d+)", precipitation_data).captures[1])

cells = Array{Any, num_gauge}

let offset_1 = 1, offset_2 = 1, steps=num_steps
    for gauge=1:num_gauge
        latitude, longitude = match(r"(?:\w|\s)+\n\s+(?<latitude>[0-9]{5,7}\.[0-9]{2})\s+(?<longitude>[0-9]{5,7}\.[0-9]{2})", precipitation_data, offset_1).captures
        println(latitude, " ", longitude)
        offset_1 = offset_1 + 2000
        #[x.captures for x in eachmatch(r".*\n\s+(?<latitude>[0-9]{5,7}\.[0-9]{2})\s+(?<longitude>[0-9]
        #grab all the coordinates
    end
end

