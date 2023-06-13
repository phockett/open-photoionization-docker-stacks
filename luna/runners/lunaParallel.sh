#!/bin/bash
# Basic script to run Luna calcs in parallel, detached with logging.
# 17/02/23


if [[ $# -eq 0 ]] ; then
    echo "ERROR: No scan name supplied."
    exit 1
fi


SCANNAME=$1
CORES="${2:-20}"

# echo $CORES

echo "Running cmd: 'julia $SCANNAME.jl -q -p $CORES |& tee $SCANNAME.log &'"

nohup julia $SCANNAME.jl -q -p $CORES |& tee $SCANNAME.log &
