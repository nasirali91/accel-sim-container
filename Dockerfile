FROM nvidia/cuda:12.6.0-cudnn-devel-ubuntu24.04

SHELL ["/bin/bash", "-c"]

WORKDIR /accel-sim

ENV CUDA_INSTALL_PATH=/usr/local/cuda
ENV PTXAS_CUDA_INSTALL_PATH=/usr/local/cuda
ENV BOOST_ROOT=/usr/include/boost
ENV PATH=$CUDA_INSTALL_PATH/bin:$PATH
ARG DEBIAN_FRONTEND=noninteractive

ENV GPUAPPS_ROOT=/accel-sim/gpu-app-collection


RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget dialog apt-utils build-essential xutils-dev bison zlib1g-dev flex \
        libglu1-mesa-dev git g++ libssl-dev libxml2-dev libxmu-dev libxi-dev libglvnd-dev libboost-all-dev vim \
        python3-setuptools python3-pip python3-venv cmake libfreeimage3 \
        libfreeimage-dev freeglut3-dev pkg-config gfortran python3-doc python3-tk \
        binfmt-support psmisc apt-utils gdb curl bash-completion \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


RUN python3 -m venv /venv \
    && /venv/bin/pip install --no-cache-dir --upgrade pip \
    && /venv/bin/pip install --no-cache-dir \
        pyyaml==6.0.1 \
        plotly==5.20.0 \
        psutil==5.9.8 
ENV PATH="/venv/bin:$PATH"


WORKDIR /accel-sim/gpu-app-collection
RUN git clone --recurse-submodules https://github.com/nasirali91/gpu-app-collection.git . 
# && bash test-build.sh  && bash get_regression_data.sh

WORKDIR /accel-sim


RUN echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    && ~/.fzf/install --all

#get Nsys
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        gnupg \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    wget -qO - https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/3bf863cc.pub | apt-key add - && \
    apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nsight-compute-2024.2.1 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nsight-systems --allow-unauthenticated && \
    rm -rf /var/lib/apt/lists/* &&\
    apt-get clean


