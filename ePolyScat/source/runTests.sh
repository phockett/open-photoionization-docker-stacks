#!/bin/bash

# Script to build and run all ePS test jobs & diff outputs
#
# Note this assumes ENV paths set $pe and working dir as per Docker.
#
# 06/07/22

useMake=false
useScript=true

# Install numdiff for testing later.
if ! command -v numdiff &> /dev/null
then
  echo "Installing numdiff"

  apt-get install -y wget
  wget http://nongnu.askapache.com/numdiff/numdiff-5.9.0.tar.gz
  tar xvfz numdiff-5.9.0.tar.gz
  cd numdiff-5.9.0
  ./configure
  make
  make install

fi

# Set timing, see https://stackoverflow.com/a/8903280
SECONDS=0
TIMES=()

# Run tests using ePS make option
# NOTE: this works OK, but stderr interleaved into output file which can cause issues
if [ "$useMake" = true ]; then
  echo "Running ePS test jobs with Makefile"

  mkdir -p ${pe}/tests/outdir.${MACH}
  cd ${pe}
  # make testall
  make test01

  # Diff files
  cd ${pe}/tests/outdir.${MACH}
  # files=*.out
  files=$(find . -type f -name 'test[0-9][0-9].out')

  for f in $files
  do
    echo "Processing $f file..."
    # take action on each file. $f store current file name
    # $epsBin $jobPath/$f 1> $jobPath/$f.out 2> $jobPath/$f.err
    # Use basename here, see https://stackoverflow.com/questions/20796200/how-to-loop-over-files-in-directory-and-change-path-and-add-suffix-to-filename
    baseName=$(basename "$f" .out)
    numdiff -E -a 1e-4 -z @ $f ${pe}/tests/${baseName}.ostnd -O > ${baseName}.diff.overview
    numdiff -E -a 1e-4 -z @ $f ${pe}/tests/${baseName}.ostnd > ${baseName}.diff

  done

fi

if [ "$useScript" = true ]; then
  echo "Running ePS test jobs with runJobs.sh, NCPUS=${NCPUS}"

  jobPath="${1:-/data}"
  epsBin="${2:-${pe}/bin/$MACH/ePolyScat}"

  # Copy test jobs
  cp ${pe}/tests/ ${jobPath} -r
  cd ${jobPath}/tests/
  # files=*.out
  files=$(find . -type f -name 'test[0-9][0-9].inp')
  N=1

  for f in $files
  do
    echo "Processing $f file..."

    jobStart=$SECONDS

    # take action on each file. $f store current file name
    baseName=$(basename "$f" .inp)
    $epsBin $jobPath/tests/$f 1> $jobPath/tests/${baseName}.out 2> $jobPath/tests/${baseName}.err
    # Use basename here, see https://stackoverflow.com/questions/20796200/how-to-loop-over-files-in-directory-and-change-path-and-add-suffix-to-filename
    numdiff -E -a 1e-4 -z @ $jobPath/tests/${baseName}.out ${pe}/tests/${baseName}.ostnd -O > ${baseName}.diff.overview
    numdiff -E -a 1e-4 -z @ $jobPath/tests/${baseName}.out ${pe}/tests/${baseName}.ostnd > ${baseName}.diff

    # Job & total timing, and log.
    duration=$SECONDS
    TIMES+=("$N","$jobStart","$(($duration-$jobStart))","$duration")

    echo "Job: $((($duration-$jobStart) / 60)) minutes and $((($duration-$jobStart) % 60)) seconds elapsed."
    echo "Total: $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
    ((N+=1))
  done

fi

# TODO: add option for manual file set
# TODO: add option for single files, e.g. make test01 etc.




duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

echo "Timing info table..."
# echo "${TIMES[@]}"
printf '%s\n' "${TIMES[@]}"
