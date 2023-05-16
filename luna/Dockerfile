# Jupyterlab with Julia and Luna.jl install.
# Uses Jupyter Stacks scipy notebook as base container, https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook
#
# 15/05/23  v1
#
# BUILD with tags:
#   sudo docker build -t luna:v150523 .
#
# RUN
#   sudo docker run -d -p 8999:8888 --name luna --rm luna:v150523


FROM jupyter/scipy-notebook


# USER $NB_UID


# Add conda env hook
COPY ./conda-activate.sh /usr/local/bin/before-notebook.d/

# Add Julia (from download)
ARG JULIA_VERSION="julia-1.8.5"
ARG JULIA_FILE="${JULIA_VERSION}-linux-x86_64.tar.gz"

RUN wget -c https://julialang-s3.julialang.org/bin/linux/x64/1.8/${JULIA_FILE} \
    && tar -xzvf ${JULIA_FILE} \
    && echo export PATH=$PATH:"/home/jovyan/${JULIA_VERSION}/bin" >> ~/.bashrc

#    && mv julia-1.8.5 /opt/   # NEEDS root

# Add path to Julia
# RUN echo export PATH=$PATH:"/home/jovyan/julia-1.8.5/bin" >> ~/.bashrc
# RUN export PATH=$PATH:"/home/jovyan/${JULIA_VERSION}/bin"

# Add Luna.jl
COPY ./julia_pkg_installs.jl .
RUN export PATH=$PATH:"/home/jovyan/${JULIA_VERSION}/bin" && julia julia_pkg_installs.jl

# FFMPEG
# RUN sudo apt update && sudo apt upgrade && sudo apt install ffmpeg
USER root
RUN apt-get update && apt-get install -y ffmpeg
USER jovyan

# Jupyter settings (optional - can also just mount settings dir here)
# 15/05/23 - CURRENTLY PASSWORD CONFIG not working? But was OK in the past? Maybe new settings required?
COPY ./jupyterSettings.sh .
RUN ./jupyterSettings.sh
