#!/bin/bash

# Script to build and run all ePS test jobs & diff outputs
#
# Note this assumes ENV paths set $pe and working dir as per Docker.
#
# 06/07/22
# 08/05/23 fixed paths issues for runJobs.sh wrapped version.

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
    numdiff -E -a 1e-4 -z @ -V $f ${pe}/tests/${baseName}.ostnd > ${baseName}.diff

  done

fi

if [ "$useScript" = true ]; then
  echo "Running ePS test jobs with runJobs.sh, NCPUS=${NCPUS}"

  # Set paths, either passed or env defaults.
  # Note this assumes jobPath == ePS tests dir, also as location of standard outputs *.ostnd
  jobPath="${1:-${pe}/tests}"
  outDir="${2:-${jobPath}/outdir.${MACH}}"
  epsBin="${3:-${pe}/bin/$MACH/ePolyScat}"

  mkdir -p ${outDir}

  # Copy test jobs
  # cp ${pe}/tests/ ${jobPath} -r
  # cd ${jobPath}/tests/

  # files=*.out
  cd ${jobPath}
  files=$(find . -type f -name 'test[0-9][0-9].inp')

  N=1

  for f in $files
  do
    echo "Processing $f file..."

    jobStart=$SECONDS

    # take action on each file. $f store current file name
    baseName=$(basename "$f" .inp)
    echo $basename
    echo "Running cmd: $epsBin $jobPath/${baseName}.inp 1> $outDir/${baseName}.out 2> $outDir/${baseName}.err"
    $epsBin $jobPath/${baseName}.inp 1> $outDir/${baseName}.out 2> $outDir/${baseName}.err
    # Use basename here, see https://stackoverflow.com/questions/20796200/how-to-loop-over-files-in-directory-and-change-path-and-add-suffix-to-filename
    # Numdiff results with some reasonable error limits.
    # This will generally just pull timing and core differences if all is well.
    # TODO: additional filtering to confirm this per file - filter diffs on line start?
    numdiff -E -r 0.01 -a 1e-4 -z @ $outDir/${baseName}.out $jobPath/${baseName}.ostnd -O > $outDir/${baseName}.diff.overview
    numdiff -E -r 0.01 -a 1e-4 -z @ -V $outDir/${baseName}.out $jobPath/${baseName}.ostnd > $outDir/${baseName}.diff

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
