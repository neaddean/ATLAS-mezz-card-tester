#!/usr/bin/python2
import serial
import time

tdc = serial.Serial("/dev/ttyUSB0", 2000000)
csr = ["000", "A00", "027", "01F", "D60", "000", "D75",
       "000", "DEB", "C0A", "A71", "E11", "1FF", "001", "000"]

asd_regs = ["FF", "07", "6C", "01", "02", "06", "05", "07", "00", "00", "1"]

def mwrite (cmd):
    if len(cmd) > 0:
        tdc.write(cmd)
    tdc.write(chr(0x0D))
    ret = ''
    while(ret != '\n'):
        ret = tdc.read()

    return

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

tdc.write("d 0 fff\n")
time.sleep(.01)
tdc.write("d 1 fff\n")
time.sleep(.01)
tdc.write("d 2 fff\n")
time.sleep(.01)
tdc.write("d 3 fff\n")
time.sleep(.01)
tdc.write("p 000000\n")
time.sleep(.01)
tdc.write("jtu\n")
time.sleep(.01)
tdc.write("jau\n")
time.sleep(.01)
tdc.write("tz\n")
time.sleep(.01)
tdc.write("sp 01\n")
time.sleep(.01)
tdc.write("tc 2\n")
time.sleep(.01)
tdc.write("tc 0\n")
time.sleep(.1)
tdc.write("tr\n")
