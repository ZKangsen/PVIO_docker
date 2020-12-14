FROM ubuntu:18.04
LABEL maintainer "kenny <https://github.com/ZKangsen>"

ENV CERES_VERSION="1.14.0"
ENV SOURCE_WS=/root/PVIO_ws
ENV DEBIAN_FRONTEND=noninteractive

      # set up thread number for building
RUN   if [ "x$(nproc)" = "x1" ] ; then export USE_PROC=1 ; \
      else export USE_PROC=$(($(nproc)/2)) ; fi && \
      apt-get update && \
      apt-get install -y wget && \
      # install cmake 3.11
      wget https://github.com/Kitware/CMake/releases/download/v3.11.0/cmake-3.11.0-Linux-x86_64.tar.gz && \
      tar -xzvf cmake-3.11.0-Linux-x86_64.tar.gz && \
      mv cmake-3.11.0-Linux-x86_64 /opt/cmake-3.11.0 && \
      ln -sf /opt/cmake-3.11.0/bin/*  /usr/bin/ && \
      apt-get install -y software-properties-common && \
      add-apt-repository ppa:ubuntu-toolchain-r/test && \
      apt-get update && \
      apt-get install -y \
      #install gcc 9.0
      gcc-9 \
      g++-9 \
      git \
      libatlas-base-dev \
      libeigen3-dev \
      libyaml-cpp-dev \
      libx11-dev \
      glibc-doc \
      manpages-posix-dev \
      xorg-dev \
      libglu1-mesa-dev \
      libglfw3-dev \
      xauth \
      # libopencv-dev is 3.2 in 18.04
      libopencv-dev \
      libgoogle-glog-dev \
      libsuitesparse-dev && \
      rm -rf /var/lib/apt/lists/* && \
      # Build and install Ceres 1.14.0
      git clone https://github.com/ceres-solver/ceres-solver.git && \
      cd ceres-solver && \
      git checkout tags/${CERES_VERSION} && \
      mkdir build && cd build && \
      cmake .. && \
      make -j$(USE_PROC) install && \
      mkdir -p $SOURCE_WS/PVIO

# choose gcc 9.0
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-9

# Copy PVIO
COPY ./ $SOURCE_WS/PVIO/

# # Build PVIO
WORKDIR $SOURCE_WS
ENV TERM xterm
RUN cd PVIO && \
    mkdir -p data && \
    mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release  .. && \
    make -j4
