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
        temp = match(r"([0-9]{5,6}\.[0-9]{2}).*?([0-9]{5,6}\.[0-9]{2})", precipitation_data, offset_1)
        gauge_coords = temp.match
        latitude = parse(Float64, temp.captures[1])
        longitude = parse(Float64, temp.captures[2])
        offset_1 = temp.offset + 1
        println(gauge_coords)
        temp = match(r"[0-9]{5,6}\.[0-9]{2}.*?[0-9]{5,6}\.[0-9]{2}.*(\n.*)*?\n.*\n.*[0-9]{5,6}\.[0-9]", precipitation_data, offset_2)
        numbers = temp.captures[1]
        print(numbers)
        print("Printed")
        nums = []
        
        let offset = 1
            for step=1:steps
                temp_num = match(r".*([0-9]{1,4}\.[0-9]{2})", numbers, offset)
                num = parse(Float64, temp_num.match)
                print(num)
                append!(nums, num)
                offset = temp_num.offset + 1
            end
        end
        println(nums)
        cells[gauge] = rain_cell(latitude, longitude, nums)
        offset_2 = temp.offset + 1
    end
end

