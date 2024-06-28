#!/bin/bash
# Basic cmake build for Docker containers
# 28/06/24

CMAKE_VERSION=${1:-3.29.6}
BASEDIR=/opt
cd $BASEDIR

echo Installing Cmake, v${CMAKE_VERSION}

#*** Install Cmake
# Recipe from Conan GCC base, https://github.com/conan-io/conan-docker-tools/blob/master/modern/base/Dockerfile
# See also https://gist.github.com/Congyuwang/203c291fa6fcac68cf364448d305a4c4
# Also script version, https://github.com/Kitware/CMake/releases/download/v3.29.6/cmake-3.29.6-linux-x86_64.sh

wget -q --no-check-certificate https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz \
    && tar -xzf cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz \
       --exclude=bin/cmake-gui \
       --exclude=doc/cmake \
       --exclude=share/cmake-${CMAKE_VERSION}/Help \
       --exclude=share/vim \
       --exclude=share/vim \
    && cp -fR cmake-${CMAKE_VERSION}-linux-x86_64/* /usr \
    && rm -rf cmake-${CMAKE_VERSION}-linux-x86_64 \
    && rm cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz