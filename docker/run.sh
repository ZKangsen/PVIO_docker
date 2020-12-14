#!/bin/bash
trap : SIGTERM SIGINT

function abspath() {
    # generate absolute path from relative path
    # $1     : relative filename
    # return : absolute path
    if [ -d "$1" ]; then
        # dir
        (cd "$1"; pwd)
    elif [ -f "$1" ]; then
        # file
        if [[ $1 = /* ]]; then
            echo "$1"
        elif [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}

DATA_DIR="$1"
CONFIG_FILE="$2"

if [ "$DATA_DIR" = "" ]; then
    echo "DATA_DIR can't be empty..."
    exit
fi
if [ "$CONFIG_FILE" = "" ]; then
    echo "CONFIG_FILE can't be empty..."
    exit
fi
echo "data path: $DATA_DIR"
echo "config file: $CONFIG_FILE"

PURE_DATA_DIR=${DATA_DIR#*//}
DATA_DIR_PREFIX=${DATA_DIR%%//*}
echo "pure data path: $PURE_DATA_DIR"
echo "data dir prefix: $DATA_DIR_PREFIX"

PVIO_DIR=$(abspath "..")
echo "PVIO_DIR: $PVIO_DIR"

sudo apt-get install x11-xserver-utils
xhost +

DOCKER_DATA_DIR="/root/PVIO_ws/PVIO/data"

sudo docker run \
  -it \
  --rm \
  --net=host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --privileged \
  -e DISPLAY=unix$DISPLAY \
  -e GDK_SCALE \
  -e GDK_DPI_SCALE \
  -v /usr/lib/nvidia-384:/usr/lib/nvidia-384 \
  -v /usr/lib32/nvidia-384:/usr/lib32/nvidia-384 \
  -v ${PVIO_DIR}:/root/PVIO_ws/PVIO/ \
  -v $PURE_DATA_DIR:$DOCKER_DATA_DIR \
  --device /dev/dri \
  myimage:PVIO \
  /bin/bash -c \
  "export PATH="/usr/lib/nvidia-384/bin":${PATH} && \
   export LD_LIBRARY_PATH="/usr/lib/nvidia-384:/usr/lib32/nvidia-384":${LD_LIBRARY_PATH} && \
   ls /root && \
   cd /root/PVIO_ws/PVIO && \
   mkdir -p build && \
   cd build && \
   cmake -DCMAKE_BUILD_TYPE=Release .. && \
   make -j4 && \
   ./pvio-pc/pvio-pc $DATA_DIR_PREFIX//$DOCKER_DATA_DIR $CONFIG_FILE"
