#!/bin/bash
# Basic script to run Jupyter/Julia Docker containers with various wrappers.
#
# 08/06/23  v1 combines previous nbconvert and julia_luna scripts with some additional logic.
#
# Run with:
#   docker-slurm-julia-dispatch.sh <scanname> <cores> <run script> <docker container>
#
# Where only <scanname> is required.
# SCANNAME is a .ipynb or .jl file for running on the node.
# CORES is the number of parallel processes to launch for the job, note this is used for .jl scripts only.
#
# TODO: convert to keyword args!
#


# ****** Script settings - NOTE THIS ASSUMES RUN WITH lunaParallel-Slurm.sh
if [[ $# -eq 0 ]] ; then
    echo "ERROR: No scan name supplied."
    exit 1
fi


SCANNAME=$1
CORES="${2:-20}"   # UPDATE: send this to Slurm as job defn.
                   # Should set using Slurm? See https://stackoverflow.com/questions/57466957/make-use-of-all-cpus-on-slurm. Or use CORES for slurm settings above.
RUNNER="${3:-"auto"}"
DOCKERIMAGE="${4:-"fock:5000/luna:v150523"}"

# Dir config
cwd=$(pwd)
DOCKERSCRIPTS="$cwd/runners"  # Dir to mount for scripts

# Check file and runner
filename=$(basename -- "$SCANNAME")
extension="${filename##*.}"
filename="${filename%.*}"

if [ -e $SCANNAME ]
then
    echo "Found input file $SCANNAME OK."
else
    echo "ERROR: Input file $SCANNAME not found."
    exit 1
fi

if [ "$RUNNER" == "auto" ]
then
#     echo "Setting runner"

    case $extension in
        jl)
            RUNNER="lunaParallel-Slurm.sh"
            echo "Set run script: $RUNNER"
            ;;
        ipynb)
            RUNNER="nbconvert-lunaParallel-Slurm.sh"
            echo "Set run script: $RUNNER"
            ;;
        *)
            echo "ERROR: Unknown file-type $extension, please run with manual run script setting to force."
            exit 1
    esac
fi


#********* DOCKER
# Non-Slurm version - just run container directly
# Basic run for test julia script
DOCKERBASEPATH="/home/jovyan/work"
DOCKERSCRIPTPATH="/home/jovyan/scripts"
CMD="docker run -v "${wd}:$DOCKERBASEPATH" -v "${DOCKERSCRIPTS}:$DOCKERSCRIPTPATH" -d --rm $DOCKERIMAGE start.sh $DOCKERSCRIPTPATH/$RUNNER $DOCKERBASEPATH/$SCANNAME $CORES"

echo Launching $CMD
$CMD
