#!/usr/bin/env python

import time
import argparse

# Create an argument parser
parser = argparse.ArgumentParser(description='Process input parameter')
parser.add_argument('--input', type=str, help='Input parameter')

# Parse the arguments
args = parser.parse_args()

# Get the input parameter value
input_value = args.input

# Sleep for 10 seconds
time.sleep(10)

# Print the input parameter
print(f"The input parameter is: {input_value}")
