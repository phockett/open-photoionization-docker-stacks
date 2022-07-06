#!/bin/bash

# Script to run all ePS jobs in a directory, *.inp
# Output files are moved to jobPath/completed.
# Very basic - to use for Docker builds.
# Copied from ePS runner https://github.com/phockett/epsman/blob/master/shell/ePS_batch_job.sh (also very basic)
#
# 01/02/22

#***** Paths
# jobPath=$1
# jobPath=/data   # Default case
jobPath="${1:-/data}"
epsBin="${2:-${pe}/bin/$MACH/ePolyScat}"   # Default assumes build paths set already in ENV


#***** Run
cd $jobPath
mkdir -p completed

files=*.inp

# echo $files

for f in $files
do
  echo "Processing $f file..."
  # take action on each file. $f store current file name
  $epsBin $jobPath/$f 1> $jobPath/$f.out 2> $jobPath/$f.err

  # cat $f

  # Move completed files? TODO: add flag for this
  mv $jobPath/$f* $jobPath/completed

done
