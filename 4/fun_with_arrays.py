#!/usr/bin/python2.7 -u
import re

fruitbox = []
veggiebox = []

fruitbox = ['dragonfruit', 'canistel', 'durian', 'salak', 'pulasan']
veggiebox = ['fiddle heads', 'oca', 'romanesco', 'kohlrabi']

print "WTF is: "
for x in fruitbox:
    print x

print "WTF is: "
for x in veggiebox:
    print x

print "Oh, I forgot some normal things!"

fruitbox.append("apple")
veggiebox.append("carrot")

healthy_things = []
healthy_things.extend(fruitbox)
healthy_things.extend(veggiebox)

list = ', '.join(healthy_things)

print "Now I  have ", list, "ok"

lunch = list.split(', ')

print "I'm lazy so here's lunch: "
for x in lunch:
    print x

# we can also split on a regex!
secondList = re.split('/\s+/', list)
print "I'm very lazy so here's dinner: "
for x in secondList:
    print x
