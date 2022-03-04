#!/usr/bin/python3
import sys

def pack_1bpp(bytes_filename,bits_filename):
    # this takes a binary file where each byte represents a pixel.
    # it packs 8 pixels into a byte, and writes the packed bytes to a new file.
    # start by reading the bytes from the file into a list of bytes
    bytes_file = open(bytes_filename, "rb+")
    bits_file = open(bits_filename, "wb+")

    bytes_list = bytes_file.read()
    # for each 8 source bytes, pack them into a single byte
    # and write the packed byte to the output file
    for i in range(0, len(bytes_list), 8):
        # grab the 8 lsbs
        bits = bytes_list[i:i+8]
        # pack them into a single byte
        packed = 0
        for j in range(8):
            packed |= (bits[j] << 7-j)
        # convert the result to a byte and write it to the output file
        bits_file.write(bytes([packed]))
        


if __name__ == "__main__":
    pack_1bpp(sys.argv[1],sys.argv[2])