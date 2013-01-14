#!/usr/bin/env python
import sys
import codecs
from bs4 import BeautifulSoup

with codecs.open(sys.argv[1], 'r', 'utf8') as infile:
    soup = BeautifulSoup(infile.read())
with codecs.open(sys.argv[1] + '.purty', 'w', 'utf8') as outfile:
    outfile.write(soup.prettify())
