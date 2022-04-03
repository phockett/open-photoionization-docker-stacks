#!/bin/bash

# Script to run all Limapack jobs in a directory, *.cfg, as `lima test.cfg test.out`
# Output files are copied to jobPath.
# Very basic - to use for Docker builds.
# Copied from ePS runner https://github.com/phockett/epsman/blob/master/shell/ePS_batch_job.sh (also very basic)
#
# 01/02/22

#***** Paths
jobPath=$1
# jobPath=/data
limapackPath=~/limapack/build/src

#***** Run
cd $jobPath
mkdir -p completed

files=*.cfg

# echo $files

for f in $files
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
  $limapackPath/lima $jobPath/$f $jobPath/$f.out

  # cat $f

  # cp $f.out ~/Dropbox/ePSjobs
  # cp $f.out /media/ext4-store/Dropbox/Dropbox/ePSjobs
  mv $f* ./completed

done
