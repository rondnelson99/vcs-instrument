#!/usr/bin/python3

# this program generates tables representing musical intervals for the Atari 2600's unique sound hardware.
# the chip takes a source frequency of around 30kHz, 
# divides that by a constant depending to the instrument (timbre) selected with AUDCx,
# divides that by an arbitrary integer between 1 and 32,
# and then outputs the resulting frequency.

# first let's define the constant divider for each of the four instruments we're using
# use a tuple for this
inst_div = (2, 6, 15, 31)

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
    if (divider * numerator % denominator == 0):
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
            if (possiblePeriod.is_integer()):
                # return the new note, which has the new divider, new instrument and bit 7 set
                return ((int(possiblePeriod) - 1) & 0x1F) | (i << 5) | 0x80
            # if we stil can't make the interval, try the next instrument
        #if none of those worked, rereturn a constant
        return 0x00
            



            

            
        