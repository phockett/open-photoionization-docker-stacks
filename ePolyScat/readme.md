# ePolyScat docker

Source code:

  Requires ePolyScat source tar file in ./source, and correct file set in the Dockerfile.

  For a copy of the source code, visit https://epolyscat.droppages.com


Basic build (takes a few minutes):

  `docker build --no-cache -f Dockerfile.UB22 -t eps .`


Run with a terminal:

  `docker run --rm -it eps`


Run with test jobs (where `-v <host-dir>:/data` mounts <host-dir> to /data in the container):

  `docker run --rm -v <host-dir>:/data eps bash -c "./testJobs.sh > /data/testLog.txt"`

Note test jobs will be in /data/tests, along with numerical diffs (via Numdiff). Logging info including timing in testLog.txt.


Run all jobs in a specified dir, e.g. <host-dir>/jobs:

  `docker run -d --rm -v <host-dir>:/data eps ./runJobs.sh /data/jobs`


Run with additional args, e.g. number of CPUS and container name

  `docker run -d --rm -v <host-dir>:/data --env NCPUS=24 --name eps24 eps ./runJobs.sh /data/jobs`
