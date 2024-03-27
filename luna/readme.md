# Luna-Docker builds

Docker builds for [Luna.jl (from Lupo Lab)](https://github.com/LupoLab/Luna.jl) Simulation of nonlinear optical dynamics — both in waveguides (such as optical fibres) and free-space geometries. (Julia)

The build is based on the [Jupyter Docker Stacks Scipy container](https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook), and adds also Julia, IJulia, Luna.jl and required packages.

## Building

### Image only

Basic build from Dockerfile and run with port-mapping:

```bash
docker build -t luna .
docker run -p 8888:8888 luna
```

where the port mapping is `host:container`.

Jupyter lab, including a Julia kernel, should then be available at http://localhost:8888.

To map files to local storage, you may also want to run with a directory mapping to `/home/jovyan/work`, which is the default Jupyter user dir (see the [Jupyter Docker Stacks docs](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html) for more details).

```bash
docker run -v <local dir>:/home/jovyan/work -p 8888:8888 luna
```

Use `exec -it <container> bash` to attach to a running container, or `run -it <container> bash` to spin one up, and connect to the terminal.

E.g. for named container as above: `docker exec -it jupyterlab_epsproc bash`



### Using Compose

Basic build with compose from the supplied `docker-compose.yml` should generally be all that is required:

```bash
docker compose build
```

Modification of various parameters may be required/desirable.

To get an interactive Jupyter session, simply run:

```bash
docker compose up
```

And point your browser to http://localhost:8999.

## General use

For general use see the [Jupyter Docker Stacks docs](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html).



## Running detached with runner scripts

For non-interactive sessions, e.g. dispatch on a cluster, there are additional runner scripts. The scripts can currently handle Jupyter notebooks and Julia scripts, and will launch and map directories as set in the script or passed at run time. For details, see the `docker-julia-dispatch.sh` (direct runs) or `docker-slurm-julia-dispatch.sh` (Slurm runs) scripts.

In general, the scripts can be called from any directory, with either of the given file types, with the syntax:

```bash

docker-slurm-julia-dispatch.sh <scanname> <cores> <run script> <docker container>

```

NOTE that the script currently HAS TO BE CALLED FROM THE WORKING DIRECTORY, containing the job to run. The script can be called using the full path if required, e.g. `<path to script>/docker-slurm-julia-dispatch.sh <scanname> <cores> <run script> <docker container>`.

For running parallel Julia process from a notebook, see https://github.com/phockett/Luna.jl-jupyterDispatch.
