# Open Photoionization Docker Stacks

Docker stacks for a range of open-source tools for simulation and analysis for photoionization problems.

03/04/22 - in progress.

Tools
-----

- Stand-alone
  - [ePolyScat](https://epolyscat.droppages.com/) Computation of electron-molecule scattering and photoionization. (Fortran) (Note this build requires user-supplied source code, see [the readme for details](https://github.com/phockett/open-photoionization-docker-stacks/tree/main/ePolyScat).)
  - [Limapack](https://github.com/jonathanunderwood/limapack) Computation of molecular aligment. (C)


- Builds with Jupyter Lab

  -[ePSproc](https://epsproc.readthedocs.io/) Post-processing for ePolyScat matrix elements, including molecular and aligned frame photoelectron angular distributions. Many tools can also be used without ePolyScat. (Python)
  - [Luna.jl (from Lupo Lab)](https://github.com/LupoLab/Luna.jl) Simulation of nonlinear optical dynamics — both in waveguides (such as optical fibres) and free-space geometries. (Julia)
  - [PEMtk](https://pemtk.readthedocs.io/) The photoelectron metrology toolkit. Experimental and theoretical analysis tools. (Python, note development version uses ePSproc on the back-end.)


To follow
---------

Gamess builds (will both require user-supplied source code).

Gamess existing Docker options:

- https://github.com/DrSnowbird/docker-hpc-gamess-ubuntu (set to local copy of source code)
- https://github.com/saromleang/docker-gamess (with source download, requires weekly password from https://www.msg.chem.iastate.edu/gamess/License_Agreement.html)
- https://catalog.ngc.nvidia.com/orgs/hpc/containers/gamess (Nvidia CUDA-accelerated version)
