#!/bin/bash

# Script to run all ePS jobs in a directory, *.inp
# Output files are moved to jobPath/completed.
# Very basic - to use for Docker builds.
# Copied from ePS runner https://github.com/phockett/epsman/blob/master/shell/ePS_batch_job.sh (also very basic)
#
# 07/07/22  Updated with more file handling and timing info
# 01/02/22  Basic version

#***** Paths
# jobPath=$1
# jobPath=/data   # Default case
jobPath="${1:-/data}"
epsBin="${2:-${pe}/bin/$MACH/ePolyScat}"   # Default assumes build paths set already in ENV


# Set timing, see https://stackoverflow.com/a/8903280
SECONDS=0
TIMES=()

#***** Run
cd $jobPath
mkdir -p completed
mkdir -p processing

files=*.inp

# echo $files
N=1

echo "Running ePS jobs with runJobs.sh, NCPUS=${NCPUS}"
echo "Start: $(date)"

for f in $files
do
  echo "Processing $f file..."
  echo "$(date)"

  # Check file still exists - may not for long-running jobs.
  if [ -f "$f" ]; then

    jobStart=$SECONDS

    # Move to processing dir
    mv $jobPath/$f $jobPath/processing/$f

    # Run ePolyScat with input file
    baseName=$(basename "$f" .inp)
    $epsBin $jobPath/processing/$f 1> $jobPath/processing/${baseName}.out 2> $jobPath/processing/${baseName}.err

    # cat $f

    # Move completed files? TODO: add flag for this
    mv $jobPath/processing/${baseName}* $jobPath/completed

    # Job & total timing, and log.
    duration=$SECONDS
    TIMES+=("$N","$jobStart","$(($duration-$jobStart))","$duration","$f")

    echo "Job: $((($duration-$jobStart) / 60)) minutes and $((($duration-$jobStart) % 60)) seconds elapsed."
    echo "Total: $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
    ((N+=1))

  else
    echo "File $f missing."

  fi

done

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

echo "Timing info table..."
# echo "${TIMES[@]}"
printf '%s\n' "${TIMES[@]}"
