#!/usr/bin/env python

import csv
import struct

with open('data/listings.csv', 'rb') as csvfile:
  with open('data/listings.bin', 'wb') as binfile:
    reader = csv.reader(csvfile)
    first = True
    for row in reader:
      if first:
        first = False
      else:
        # station, commodity, supply, demand, buy, sell, collected_at
        s = struct.pack("7I", int(row[1]), int(row[2]), int(row[3]),
            int(row[6]), int(row[4]), int(row[5]), int(row[7]))
        binfile.write(s)

