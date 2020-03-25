in_path = ARGS[1]

out_path = try
                ARGS[2]
            catch
                replace(in_path, ".csv" => "_formatted.csv")
            end

file = open(in_path, "r")
file_content = read(file, String)
file_check = eachmatch(r"(?<day>\d{1,2})/(?<month>\d{1,2})/(?<year>\d{4}) (?<hour>\d{1,2}):(?<minute>\d{1,2}),(?<wl19>\d{0,9}.?\d{0,9}),(?<wl2>\d{0,9}.?\d{0,9}),(?<wl21>\d{0,9}.?\d{0,9})", file_content)
timesteps = [replace(x[:year]*"-"*x[:month]*"-"*x[:day]*" "*x[:hour]*":"*x[:minute], r"\D(\d):(\d{2})" => s" 0\1:\2") for x in file_check]

data = Dict()
data["19"] = [each[:wl19] for each in file_check]
data["2"] = [each[:wl2] for each in file_check]
data["21"] = [replace(each[:wl21], r"\r" => "") for each in file_check]

names = Dict()
names["19"] = "Lagoon"
names["2"] = "Cabbage_in"
names["21"] = "Cabbage"

file_out = open(out_path, "w")
write(file_out, "name,id,"*join(timesteps, ",")*"\n")
for level_id in ["19", "2", "21"]
    write(file_out, names[level_id]*","*level_id*","*join(data[level_id], ",")*"\n")
end