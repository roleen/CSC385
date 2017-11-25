filehandle = open("main.s", "r")
main_contents = filehandle.readlines()
filehandle.close()

filehandle = open("playback.s", "r")
playback_contents = filehandle.readlines()
filehandle.close()

filehandle = open("recorder.s", "r")
recorder_contents = filehandle.readlines()
filehandle.close()

# Read data section
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
    return exceptions


output = read_data(main_contents, "main")
output += read_data(playback_contents, "playback")
output += read_data(recorder_contents, "recorder")

output += "\n.global _start\n"

output += read_instructions(main_contents, "main")
output += read_instructions(playback_contents, "playback")
output += read_instructions(recorder_contents, "recorder")

output += '\n.section .exceptions, "ax"\n'
output += read_exceptions(main_contents, "main")
output += read_exceptions(playback_contents, "playback")
output += read_exceptions(recorder_contents, "recorder")

filehandle = open("combined.s", "w")
filehandle.write(output)
filehandle.close()