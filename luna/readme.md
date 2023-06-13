# Luna-Docker builds

Docker builds for [Luna.jl (from Lupo Lab)](https://github.com/LupoLab/Luna.jl) Simulation of nonlinear optical dynamics — both in waveguides (such as optical fibres) and free-space geometries. (Julia)

The build is based on the [Jupyter Docker Stacks Scipy container](https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook), and adds also Julia, IJulia, Luna.jl and required packages.

## Building

Basic build with compose from the supplied `docker-compose.yml` should generally be all that is required:

  `docker compose build`

Modification of various parameters may be required/desirable.

## General use

For general use see the [Jupyter Docker Stacks docs](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html).

To get an interactive Jupyter session, simply run:

  `docker compose up`

And point your browser to http://localhost:8999.

## Running detached with runner scripts

For non-interactive sessions, e.g. dispatch on a cluster, there are additional runner scripts. The scripts can currently handle Jupyter notebooks and Julia scripts, and will launch and map directories as set in the script or passed at run time. For details, see the `docker-julia-dispatch.sh` (direct runs) or `docker-slurm-julia-dispatch.sh` (Slurm runs) scripts.

In general, the scripts can be called from any directory, with either of the given file types, with the syntax:

```bash

docker-slurm-julia-dispatch.sh <scanname> <cores> <run script> <docker container>

```

NOTE that the script currently HAS TO BE CALLED FROM THE WORKING DIRECTORY, containing the job to run. The script can be called using the full path if required, e.g. `<path to script>/docker-slurm-julia-dispatch.sh <scanname> <cores> <run script> <docker container>`.
