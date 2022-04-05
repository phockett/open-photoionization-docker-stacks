# Open Photoionization Docker Stacks

Docker stacks for a range of open-source tools for simulation and analysis for photoionization problems.

03/04/22 - in progress.

Tools
-----

- [Limapack](https://github.com/jonathanunderwood/limapack) Computation of molecular aligment. (C)
- [ePSproc](https://epsproc.readthedocs.io/) Post-processing for ePolyScat matrix elements, including molecular and aligned frame photoelectron angular distributions. Many tools can also be used without ePolyScat. (Python)
- [PEMtk](https://pemtk.readthedocs.io/) The photoelectron metrology toolkit. Experimental and theoretical analysis tools. (Python, note development version uses ePSproc on the back-end.)


To follow
---------

ePolyScat & Gamess builds (will both require user-supplied source code).

Gamess existing Docker options:

- https://github.com/DrSnowbird/docker-hpc-gamess-ubuntu (set to local copy of source code)
- https://github.com/saromleang/docker-gamess (with source download, requires weekly password from https://www.msg.chem.iastate.edu/gamess/License_Agreement.html)
- https://catalog.ngc.nvidia.com/orgs/hpc/containers/gamess (Nvidia CUDA-accelerated version)
