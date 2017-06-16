"""

Highlights Vivado output messages according to their severity

"""

import sys

# Define some normal and bright colors - may not use all of these
green =
bright_green =
yellow =
bright_yellow =
orange =
bright_orange =
red =
bright_red =
blue =
bright_blue =
bright_white =
reset =

MESSAGES = {'STATUS' : bright_white,
            'INFO' : bright_white,
            'WARNING'  : yellow,
            'CRITICAL WARNING' : orange,
            'ERROR' : red}

def main():
    for line in sys.stdin:
        pass

def color_line(line):
    for message in MESSAGES:
        if line.startswith(message):
