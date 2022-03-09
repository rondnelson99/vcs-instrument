#!/usr/bin/python3
import sys


# this program generates tables representing musical intervals for the Atari 2600's unique sound hardware.
# the chip takes a source frequency of around 30kHz, 
# divides that by a constant depending to the instrument (timbre) selected with AUDCx,
# divides that by an arbitrary integer between 1 and 32,
# and then outputs the resulting frequency.

# first let's define the constant divider for each of the four instruments we're using
# use a tuple for this
inst_div = (2, 6, 15, 31)
# another tuple will hold all the desired intervals as numerator/denominator pairs
# each one of these will eat up 128 bytes of the ROM
intervals = (
    (1,2), # up an octave
    (2,1), # down an octave
    (2,3), # up a fifth
    (3,2), # down a fifth
)

# the main part of this script is the function that generates the byte representing the note 
# resulting from an interval applied to the source note. 
# It takes the source note bitfield and the interval (numerator and denominator)
# it returns the resulting note bitfield.

# the format for these bitfields is as follows:
# bits 0-4 are the frequency divider. The 0-31 range is actually 1-32.
# bits 5-6 select one of the four instruments (0-3). These are coverted into AUDCx values at runtime.
# bit 7 is set if the interval can be properly formed by the atari. 
# If it's not set, the interval will be approximated and will sound out of tune.

def interval_byte( oldNote, numerator, denominator):
    # isolate the divider
    divider = (oldNote & 0x1F) + 1
    # calculate the period based on the divider and the instrument
    period = (divider * inst_div[(oldNote >> 5) & 0b11])

    # if we can, we'll use the original instrument to make the interval. That will sound better.
    if ((divider * numerator % denominator == 0) and (period * numerator // denominator <= 32)):
        newDivider = divider * numerator // denominator
        # return the new note, which has the new divider, original instrument and bit 7 set
        return ((newDivider - 1) & 0x1F) | (oldNote & 0b01100000) | 0x80
    # if that didn't work, then we try the other instruments and see if any of them can make the interval.
    # if so, we'll use that instrument.
    else:
        for i in range(4):
            # if the period / instrument divider * numerator / denominator is an integer, we can make the interval
            possiblePeriod = (period / inst_div[i] * numerator / denominator)
            # if it's an integer, we can make the interval
            if (possiblePeriod.is_integer() and possiblePeriod <= 32):
                # return the new note, which has the new divider, new instrument and bit 7 set
                return ((int(possiblePeriod) - 1) & 0x1F) | (i << 5) | 0x80
            # if we stil can't make the interval, try the next instrument
        #if none of those worked, rereturn a constant
        return 0x00

def interval_table(numerator,denominator): 
    # this function generates the table of the notes resulting from an interval applied to all possible source notes
    # generate the table
    table = []
    for i in range(0x80):
        table.append(interval_byte(i,numerator,denominator))
    # return the table
    return table

def generate_all_tables(output_filename):
    # this function generates all the tables and writes them to a file
    # it takes the name of the output file as an argument
    # first, we'll generate the tables for all the intervals
    # open the binary file for writing
    output_file = open(output_filename, "wb+")
    # write the tables for each interval
    for i in range(len(intervals)):
        output_file.write(bytes(interval_table(intervals[i][0],intervals[i][1])))
    # close the file
    output_file.close()


if __name__ == "__main__":
    generate_all_tables(sys.argv[1])


            

            
        