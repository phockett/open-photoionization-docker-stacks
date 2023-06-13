#!/bin/bash
# Basic script to run Jupyter/Julia Docker containers via Slurm, with various wrappers.
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
DOCKERSCRIPTS="/software/docker/luna-fock/slurm-templates"  # Dir to mount for scripts

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


#********* DOCKER & SLURM RUN

# Heredoc, use to create direct output stream to file
# NOTE use eval form, then \$ for local variables, and $ for passed vars (set above).
cat > $filename.slurm <<eoi
#!/bin/bash

# ****** SLURM CONFIG
#SBATCH -N 1   # Run on 1 node
#SBATCH -n 1   # nTasks - note this launches N copies of SAME TASK in this case! Note: only an issue if using srun tasks, see https://stackoverflow.com/questions/39186698/what-does-the-ntasks-or-n-tasks-does-in-slurm
#SBATCH -J luna-docker
#SBATCH --mem=0   # No mem limit
#SBATCH -t 5:00:00   # NEED TO SET timelimit, otherwise defaults to 1 min, this is H:M:S
#SBATCH --cpus-per-task $CORES # NEEDS TO BE SET, default is 1? For Docker runs seems OK to leave this unset, parallel processes still dispatched?

# load the environment, this gives $WORK
module load environment


# ******* File handling

# Set work dir on node
wd=\$WORK/\$SLURM_JOB_ID
mkdir -p \$wd
chmod a+wrx \$wd  # Add all user permissions to avoid IO issues from Docker

# echo $SLURM_JOB_ID
echo "Created working dir \$wd on node \$(hostname)"
# Copy required files

cp $cwd/$RUNNER \$wd
cp $cwd/$SCANNAME \$wd


# ******** Launch job

# Do some work...
# Basic run for test julia script
DOCKERBASEPATH="/home/jovyan/work"
DOCKERSCRIPTPATH="/home/jovyan/scripts"
CMD="docker run -v "\${wd}:\$DOCKERBASEPATH" -v "${DOCKERSCRIPTS}:\$DOCKERSCRIPTPATH" --rm $DOCKERIMAGE start.sh \$DOCKERSCRIPTPATH/$RUNNER \$DOCKERBASEPATH/$SCANNAME $CORES"

echo Launching \$CMD
srun \$CMD


# ********* Clean up

echo Copying files from node to $cwd/\$SLURM_JOB_ID
# mkdir $cwd/$SLURM_JOB_ID
# cp -rf * $cwd/$SLURM_JOB_ID
cp \$wd . -r
echo done.

echo Removing the working directory: \$wd
rm -rf \$wd
echo done.
echo exiting.


eoi

echo Written Slurm job to $filename.slurm. Dispatching to sbatch...

sbatch $filename.slurm
