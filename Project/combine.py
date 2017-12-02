def read_input_file(filename):
    filehandle = open(filename, "r")
    contents = filehandle.readlines()
    filehandle.close()
    return contents

def read_data(contents, label):
    data = "#### " + label + " data ####\n"
    while not(contents[0].startswith(".global")):
        data += contents.pop(0)
    return data.strip() + "\n"

def read_instructions(contents, label):
    instructions = "#### " + label + " instructions ####\n"
    while len(contents) > 0 and not(".section" in contents[0] and ".exceptions" in contents[0]):
        instruction = contents.pop(0)
        if not(instruction.strip().startswith(".global")):
            instructions += instruction
    return instructions.strip() + "\n"

def read_exceptions(contents, label):
    exceptions = "#### " + label + " exceptions ####\n"
    while len(contents) > 0:
        instruction = contents.pop(0)
        if not(".section" in instruction and ".exceptions" in instruction):
            exceptions += instruction
    return exceptions.strip() + "\n"

main_contents = read_input_file("main.s")
playback_contents = read_input_file("playback.s")
recorder_contents = read_input_file("recorder.s")
indicators_contents = read_input_file("indicators.s")

output = read_data(playback_contents, "playback")
output += read_data(recorder_contents, "recorder")
output += read_data(indicators_contents, "indicators")
output += read_data(main_contents, "main")

output += "\n.global _start\n"

output += read_instructions(main_contents, "main")
output += read_instructions(playback_contents, "playback")
output += read_instructions(recorder_contents, "recorder")
output += read_instructions(indicators_contents, "indicators")

output += '\n.section .exceptions, "ax"\n'
output += read_exceptions(main_contents, "main")
output += read_exceptions(playback_contents, "playback")
output += read_exceptions(recorder_contents, "recorder")
output += read_exceptions(indicators_contents, "indicators")

filehandle = open("combined.s", "w")
filehandle.write(output)
filehandle.close()