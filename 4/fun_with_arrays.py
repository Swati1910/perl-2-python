#!/usr/bin/python2.7 -u

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
healthy_things.append(fruitbox)
healthy_things.append(veggiebox)

print "Now I have:"
for x in healthy_things:
    print x
