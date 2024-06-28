# RMT docker

Build RMT and associated tools:

- RMT, R-matrix II, source pulled from the team repo at https://gitlab.com/Uk-amor/RMT/
- UKRmol+ and tools, from Zenodo versions (see `scripts/build_ukrmol.sh` for details), circa Dec. 2020:
    - [GBTOLib v3.0.3](https://zenodo.org/records/5798035).
    - [UKRMol+: UKRMol-in v3.2](https://zenodo.org/records/5799110)
    - [UKRMol+: UKRMol-out v3.2](https://zenodo.org/records/5799134)
    

For RMT details: Brown, Andrew C., Gregory S. J. Armstrong, Jakub Benda, Daniel D. A. Clarke, Jack Wragg, Kathryn R. Hamilton, Zdeněk Mašín, Jimena D. Gorfinkiel, and Hugo W. van der Hart. 2020. “RMT: R-Matrix with Time-Dependence. Solving the Semi-Relativistic, Time-Dependent Schrödinger Equation for General, Multielectron Atoms and Molecules in Intense, Ultrashort, Arbitrarily Polarized Laser Pulses.” Computer Physics Communications 250 (May):107062. https://doi.org/10.1016/j.cpc.2019.107062, arXiv: https://arxiv.org/abs/1905.06156



Basic build:

  `docker build -f Dockerfile.UB-gfort -t rmt .`


Run with a terminal:

  `docker run --rm -it rmt`



TODO:

- Scripts to run tests.
- Python builds.
