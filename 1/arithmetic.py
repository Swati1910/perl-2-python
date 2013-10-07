#!/usr/bin/python2.7 -u

# arithmetic operators: + - * / % **
# nb: ** is exponentiation and binds even 
#	more tightly than unary minus, so -2**4 is -(2**4), not (-2)**4.

x = 20
y = 22.2

z = x + y

print z

a = z - x

print a

b = x * a

print b
b = b * a

l = b/100

print l

starStared = x**2
print starStared

total = x-y+l/b%starStared
print total
