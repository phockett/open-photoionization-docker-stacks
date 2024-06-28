#!/bin/bash
#
# Download and build UKRmol+ components
# 26/06/24, PH
#
# Note this pulls from Zenodo, versions Dec. 2021. Should be on Gitlab (https://gitlab.com/UK-AMOR/UKRMol) but currently private (although RMT and R-matrix II are not)
#
# STATUS:
#   - Builds OK
#   - Tests on GBTOLib running OK
#   - MAY need additional libs for full UKRmol-in builds? (See relevant readme).
#   - DIDN't yet run tests on UKRmol in or out builds.

# mkdir ukrmolSource
# cd ukrmolSource

BASEDIR=/opt
cd $BASEDIR

# Optional if not configured in base env - ACUTALLY not required currently.
# BLAS_DIR=${BLAS_DIR:-/usr/lib/atlas-base}
# MPI_DIR=${MPI_DIR:-/usr/lib/openmpi}
# LD_LIBRARY_PATH=${BLAS_DIR}:$LD_LIBRARY_PATH
# LD_LIBRARY_PATH=${MPI_DIR}:$LD_LIBRARY_PATH

#*** GET SOURCE
echo *** Downloading source files...

# GBTOLib
GBTO_DISTRO="GBTOLib-3.0.3"
wget -q --no-check-certificate https://zenodo.org/records/5798035/files/${GBTO_DISTRO}.zip
unzip ${GBTO_DISTRO}.zip

# UKRmol+: UKRmol-in
UKRMOLIN_DISTRO="ukrmol-in-3.2"
wget -q --no-check-certificate https://zenodo.org/records/5799110/files/${UKRMOLIN_DISTRO}.tar.gz
tar -xzf ${UKRMOLIN_DISTRO}.tar.gz

# UKRmol+: UKRmol-out
UKRMOLOUT_DISTRO="ukrmol-out-3.2"
wget -q --no-check-certificate https://zenodo.org/records/5799134/files/${UKRMOLOUT_DISTRO}.tar.gz
tar -xzf ${UKRMOLOUT_DISTRO}.tar.gz


#*** BUILD GBTOLib
echo *** Building GBTOLib

cd $BASEDIR/$GBTO_DISTRO
mkdir build && cd build

# Cmake config - from root README.md
# Modified here to use gcc etc (rather than icc etc), but may want to stick with Intel compilers, and Intel MKL...?
cmake -D CMAKE_C_COMPILER=$(which gcc) \
     -D CMAKE_CXX_COMPILER=$(which g++) \
     -D CMAKE_Fortran_COMPILER=$(which mpifort) \
     ..

make

# Optional - run tests. Takes a while (~hours on Fock, seemed to use 4 cores only?).
# make test


#*** BUILD UKRmol+ in
echo *** Building UKRmol+: UKRmol-in

cd $BASEDIR/$UKRMOLIN_DISTRO
mkdir build && cd build

# Cmake config - from root README.md
# Modified here to use gcc etc (rather than icc etc), but may want to stick with Intel compilers, and Intel MKL...?
# NOTE FLAG for gfortran, may also want to add elsewhere
cmake -D CMAKE_C_COMPILER=$(which gcc) \
     -D CMAKE_CXX_COMPILER=$(which g++) \
     -D CMAKE_Fortran_COMPILER=$(which mpifort) \
      -D CMAKE_Fortran_FLAGS="-fdefault-integer-8" \
      ..

make

# TESTS TO DO:
# SEE ALSO /opt/ukrmol-in-3.2/tests/suite/README.md for more.
#     ctest -R serial
#     mv ./Testing Testing_serial
#     ctest -R parallel
#     mv ./Testing Testing_parallel



#*** BUILD UKRmol+ out
echo *** Building UKRmol+: UKRmol-out

cd $BASEDIR/$UKRMOLOUT_DISTRO
mkdir build && cd build


# Cmake config - from root README.md
# Modified here to use gcc etc (rather than icc etc), but may want to stick with Intel compilers, and Intel MKL...?
# NTOE: needs GBTOLIB paths here?  But not for -in case? Although do appear in compilation outputs...?
cmake -D CMAKE_C_COMPILER=$(which gcc) \
     -D CMAKE_CXX_COMPILER=$(which g++) \
     -D CMAKE_Fortran_COMPILER=$(which mpifort) \
     -D GBTOLIB_INCLUDE_DIRS="$BASEDIR/$GBTO_DISTRO/build/mod" \
     -D GBTOLIB_LIBRARIES="$BASEDIR/$GBTO_DISTRO/build/lib/libGBTO.a" \
    ..

make
