#!/bin/env python

from pylab import *
import pysam
import re
from collections import defaultdict
import numpy as np
import sys
import collections
from numpy import binary_repr
from collections import OrderedDict
import os


##################################
## This script takes a BAM file ##
## and delivers a file with the ##
##   a list of all its flags &  ##
##   meanings plus a file with  ##
##   the fragment lenghts for   ##
##     propper paired reads     ##
##################################


## get the sample or file form sys.stdarg
SAM = ""
outD  = "."
if len(sys.argv)>1:
    SAM=sys.argv[1]
if len(sys.argv)>2:
    outD=sys.argv[2]

try:
    os.makedirs(outD)
except:
    pass

samfile=pysam.Samfile(SAM,"rb")

flags = defaultdict(lambda : defaultdict(int))
fragmentLengths = defaultdict(lambda : defaultdict(int))

for rn,read in enumerate(samfile):

    ## flag distribution
    flags[rg][read.flag]+=1

    ## fragment length
    if read.is_proper_pair and read.isize>0:
       fragmentLengths[rg][read.isize]+=1

### print flags
for read_group,flagH in flags.items():
    OF=open(outD + '/flagHist_'+read_group+'_V3.txt','w')
    OF.write("\t".join('SamFlag SuppAlign PCRdup FailQ SecAln SecinPair FirstinPair MateRevS ReadRevS MateUnmpp ReadUnmpp PropperPair Paired NumberOfReads'.split()) + '\n')
    for flag,nRds in sorted(flagH.items(), key=lambda t: (-t[1],-t[0])):
        OF.write("\t".join([str(flag)] + list(binary_repr(flag,width=12)) + [str(nRds)]) + "\n")
    OF.close()


### print the fragment lenghts by read group and the number of reads with that flag
for read_group,frgH in fragmentLengths.items():
    OF=open(outD + '/fragmentLengthHist_'+read_group+'.txt','w')
    OF.write('fragmentLength\tNumberOfReads\n')
    for fl,nr in sorted(frgH.items()):
        OF.write('%d\t%d\n' % (fl,nr))
    OF.close()
