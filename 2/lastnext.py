#!/usr/bin/python2.7 -u
# last and next in perl = break and continue in python

a = 0

while a < 10:
    a += 1
    if a == 5:
        continue
    print a
    if a == 7:
        break
