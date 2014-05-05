#!/usr/bin/python2
import serial
import time

tdc = serial.Serial("/dev/ttyUSB0", 500000)
csr = ["000", "020", "027", "01F", "D60", "000", "D75",
       "000", "DEB", "C0A", "A71", "E11", "1FF", "FFF"]

tdc.write("power_off\n")
time.sleep(1)
tdc.write("power_on\n")
time.sleep(1)

for i in range(len(csr)):
    tdc.write("jtw " + format(i, "1x") + " " + csr[i] + "\n")

tdc.write("jtu\n")
tdc.write("tz\n")
tdc.write("tc 2\n")
tdc.write("tc 0\n")
tdc.write("tr\n")
