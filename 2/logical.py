#!/usr/bin/python2.7 -u
# logical operators: || && ! and or not

print "Logical Operator test"
a = 11
b = 10

if a > b and b < 100:
    answer = "yes"
else:
    answer = "no"
print answer

c = 0

if a and c:
    print "Nothing to see here..."
else:
    print "Didn't see anything..."

if not c:
    print "But we will see this!"

if a and c or b:
    print "and has lower precedence than ||"

if a and c or c:
    print "&& has higher precedence than or"

if a and not c:
    print "not not not and and and"
