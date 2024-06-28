# RMT docker

Build RMT and associated tools:

- RMT, R-matrix II, source pulled from the team repo at https://gitlab.com/Uk-amor/RMT/
- UKRmol+ and tools, from Zenodo versions (see `scripts/build_ukrmol.sh` for details).


Basic build:

  `docker build -f Dockerfile.UB-gfort -t rmt .`


Run with a terminal:

  `docker run --rm -it rmt`



TODO:

- Scripts to run tests.
- Python builds.
