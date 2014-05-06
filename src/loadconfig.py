#!/usr/bin/python2
import serial
import time

tdc = serial.Serial("/dev/ttyUSB0", 500000)
csr = ["000", "020", "027", "01F", "D60", "000", "D75",
       "000", "DEB", "C0A", "A71", "E11", "1FF", "FFF"]

asd_regs = ["FF", "07", "6C", "06", "02", "06", "02", "07", "55", "55", "00"]

tdc.write("power_off\n")
time.sleep(1)
tdc.write("power_on\n")
time.sleep(1)

for i in range(len(csr)):
    tdc.write("jtw " + format(i, "1x") + " " + csr[i] + "\n")

for i in range(len(asd_regs)):
    tdc.write("jaw " + format(i, "1x") + " " + asd_regs[i] + "\n")


tdc.write("jtu\n")
tdc.write("jau\n")
tdc.write("tz\n")
tdc.write("tc 2\n")
tdc.write("tc 0\n")
tdc.write("tr\n")


