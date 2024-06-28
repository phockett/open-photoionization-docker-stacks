#!/bin/bash
#
# Download and build RMT & R-matrix II
# 28/06/24, PH
#
# Note this pulls source code from Gitlab repo (open access)
#

BASEDIR=/opt
cd $BASEDIR

#*** GET SOURCE
echo *** Downloading source files...

git clone https://gitlab.com/Uk-amor/RMT/rmt
git clone https://gitlab.com/Uk-amor/RMT/rmatrixII


#*** Build RMT
echo *** Building RMT with cmake...

export CC=$(which mpicc) && \
    export CXX=$(which mpicxx) && \
    export FC=$(which mpif90) && \
    cd rmt && mkdir build && cd build && \
    cmake ../source && make
    
    
#*** Build R-matrix II
# See https://gitlab.com/Uk-amor/RMT/rmatrixII/-/blob/master/docs/instructions?ref_type=heads
# NOTE: built OK in testing, although lots of compiler warnings using gfortran, may need to add some flags.
# For UKRmol+ used "-D CMAKE_Fortran_FLAGS="-fdefault-integer-8""

export FC=$(which gfortran) && \
    cd rmatrixII && mkdir build && cd build && \
    cmake ../source && make