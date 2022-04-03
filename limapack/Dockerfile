# Test build for Limapack using GCC4.8
# 01/02/22
# Build OK on Jake with
#   docker build -t limapack --no-cache .
#
# To ignore apt-update errors used `; exit 0`.
#   Better: `RUN <first stage> && <job that might fail> || true && <next stage>`
#   Or log: make test 2>&1 > /where/ever/make.log || echo "There were failing tests!"
#   See https://stackoverflow.com/questions/30716937/dockerfile-build-possible-to-ignore-error/30717108

# Base image with GCC4.8, Cmake etc., see https://github.com/conan-io/conan-docker-tools/blob/master/gcc_4.8/Dockerfile
# Note base is Ubuntu:Trusty
FROM conanio/gcc48

# Add prereq libs - seems OK without specific versions here
# RUN sudo apt-get update
# RUN sudo apt-get install libgsl0-dev libconfig-dev libhdf5-dev

# Above OK interactively, but throws errors on Dockerfile build... try this method instead...
# From https://github.com/docker-library/golang
# Issues seem to arise from some missing (but unimportant) repos on apt-get update... may need --ignore-missing?
# Also  rebuild with `--no-cache` to force `docker build -t limapack --no-cache .`
# Also add `; exit 0` to ignore error return.
# RUN sudo apt-get update --ignore-missing; exit 0 && \
# 	apt-get install -y --no-install-recommends \
# 	libgsl0-dev libconfig-dev libhdf5-dev \
# 	&& rm -rf /var/lib/apt/lists/*
# ABOVE fails for some reason... get to build but missing libconfig? exit 0 skips apt-get?

# 3rd attempt...
RUN sudo apt-get update --ignore-missing; exit 0
RUN sudo apt-get install -y --no-install-recommends \
    libgsl0-dev libconfig-dev libhdf5-dev

# Clone & build Limapack
RUN git clone https://github.com/jonathanunderwood/limapack.git
RUN cd limapack && mkdir build && cd build && \
	cmake ../ && make

# Set data dir for mounting to
RUN sudo mkdir /data && sudo chmod a+rwx /data

# COPY runJobs.sh /data
