#!/usr/bin/python2

import serial

Mezz = serial.Serial("/dev/ttyUSB1", 115200)



def do_write(cmd):
    if len(cmd) > 0:
        Mezz.write(cmd)
    Mezz.write("\n")
    print(cmd)
    # ret = ''
    # while (ret != "\n"):
    #     ret = Mezz.read()

def jw (jtag_param):
    towrite = "0" + str(int(jtag_param[0] + "0" + jtag_param[1],2))
    do_write("jw " + towrite)
    towrite = "0" + str(int(jtag_param[0] + "1" + jtag_param[1],2))
    do_write("jw " + towrite)
    print ("write : "+ jtag_param)
    
def jr():
    Mezz.flushInput()
    Mezz.write('jr' + '\n')
    Mezz.flushInput()
    result = Mezz.readline()
    result = Mezz.readline()
    print ("read :  " + result)

JTAG = ["10", "10", "00", "10", "10", "01", "01", "01", "01",
        "01", "01", "01", "01", "01", "01","01", "01", "01",
        "01", "01", "01", "11", "11"]

for i in JTAG:
    jw(i)
    #jr()
