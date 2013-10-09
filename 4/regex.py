#!/usr/bin/python2.7 -u
import re

# regex demo

word = "1234abc5678def"

word = re.sub(r'[0-9]', '', word, 1)
print word

word = re.sub(r'[0-9]', '', word)
print word
