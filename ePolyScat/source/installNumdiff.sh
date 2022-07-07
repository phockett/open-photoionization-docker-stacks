#!/bin/bash

# Install numdiff
# See http://www.nongnu.org/numdiff/
#
# NOTE: on Ubuntu can also just `sudo apt install numdiff`

apt-get install -y wget
wget http://nongnu.askapache.com/numdiff/numdiff-5.9.0.tar.gz
tar xvfz numdiff-5.9.0.tar.gz
cd numdiff-5.9.0
./configure
make
make install
