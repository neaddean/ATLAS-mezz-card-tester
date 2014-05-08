#!/usr/bin/python2
import serial
import time

tdc = serial.Serial("/dev/ttyUSB0", 500000)
csr = ["000", "020", "027", "01F", "D60", "000", "D75",
       "000", "DEB", "C0A", "A71", "E11", "1FF", "FFF", "FFF"]

asd_regs = ["FF", "07", "6C", "01", "02", "06", "05", "07", "00", "00", "00"]

tdc.write("power_off\n")
time.sleep(1)
tdc.write("power_on\n")
time.sleep(1)

for i in range(len(csr)):
    tdc.write("jtw " + format(i, "1x") + " " + csr[i] + "\n")
    time.sleep(.01)


for i in range(len(asd_regs)):
    tdc.write("jaw " + format(i, "1x") + " " + asd_regs[i] + "\n")
    time.sleep(.01)

tdc.write("jtu\n")
time.sleep(.01)
tdc.write("jau\n")
time.sleep(.01)
tdc.write("tz\n")
time.sleep(.01)
tdc.write("tc 2\n")
time.sleep(.01)
tdc.write("tc 0\n")
time.sleep(.1)
tdc.write("tr\n")
