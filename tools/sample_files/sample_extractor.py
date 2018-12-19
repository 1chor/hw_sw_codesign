
left = []
right = []

f = open( "hexdump_ir_short", "r" )
lines = f.readlines()

# the hexdump_ir_short does not have the wav header anymore

# go through the first line seperatly because it has only one sample

erste_samples = lines[0].split(" ")

left.append(erste_samples[0])
right.append(erste_samples[1][:-1]) # [:-1] to remove "\n"

# [1:] to cut off the first line

for line in lines[1:]:
    
    samples = line.split(" ")
    
    # first col is some addr shit we don't need.
    # so we start at 1.
    # also no loop because fuck it.
    
    # the last samples are not in a full line similar to the first ones
    # we do not care about those.
    # they will trigger the inxed error.
    
    try:
        
        left.append(samples[1])
        right.append(samples[2])
        
        left.append(samples[3])
        right.append(samples[4])
        
        left.append(samples[5])
        right.append(samples[6])
        
        left.append(samples[7])
        right.append(samples[8][:-1]) # get rid of "\n"
        
    except IndexError:
        pass

# now we have 2 lists. one for each channel.

# write left

left_str = "".join(left)

left_f = open("./left_samples", "w")

left_f.write(left_str)

# write right

right_str = "".join(right)

right_f = open("./right_samples", "w")

right_f.write(right_str)
