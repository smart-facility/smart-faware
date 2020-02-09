function grab_tag(string, tag)
    tag = match(Regex("\"$tag\":.*?(.*?),"), string)
    return tag.captures[1]
end

data_directory = "data/mqtt"
data_files = readdir(data_directory)
filename = data_directory*"/"*data_files[1]

file = open(filename, "r")
file_content = read(file, String)



tag = grab_tag(file_content, "data_rate")
println(tag)

tag = grab_tag(file_content, "altitude")
println(tag)