#!/bin/bash
# Basic script to run Luna calcs in parallel, detached with logging.
# SLURM TEST VERSION - run without bg/nohup to ensure job completion in Slurm launched Docker run.
# UPDATE: now running via docker-slurm-julia-dispatch.sh, with only minor changes here for current Docker Luna build.
# vSlurm 07/06/23
# v1 17/02/23


if [[ $# -eq 0 ]] ; then
    echo "ERROR: No scan name supplied."
    exit 1
fi


SCANNAME=$1
CORES="${2:-20}"

# echo $CORES

echo "Running cmd: 'julia $SCANNAME -q -p $CORES |& tee $SCANNAME.log &'"

export PATH=$PATH:/home/jovyan/julia-1.8.5/bin   # For direct docker CLI runs seem to need full path here, not sure why, but container fails otherwise, see notes below.
mkdir /home/jovyan/.luna   # Need temp dir too, for parallel run case at least, may be missing in docker host

julia $SCANNAME -q -p $CORES |& tee $SCANNAME.log
