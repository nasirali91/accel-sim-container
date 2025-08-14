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
        psutil==5.9.8 # IMPORTANT: Replace with actual versions you've tested!
        
ENV PATH="/venv/bin:$PATH"


WORKDIR /accel-sim/gpu-app-collection
RUN git clone --recurse-submodules https://github.com/nasirali91/gpu-app-collection.git . \
    && bash test-build.sh \
    && bash get_regression_data.sh

WORKDIR /accel-sim


RUN echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc \
    && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
    && ~/.fzf/install --all

#get Nsys
ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008,DL4006
RUN set -o pipefail; \
    apt-get update --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends gnupg wget \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO - https://developer.download.nvidia.com/devtools/repos/ubuntu2404/amd64/7fa2af80.pub | tee /etc/apt/keyrings/nvidia.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/nvidia.asc] http://developer.download.nvidia.com/devtools/repos/ubuntu2404/amd64 /" | tee /etc/apt/sources.list.d/nvidia.list \
    && apt-get update --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends nsight-systems-cli --allow-unauthenticated \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
