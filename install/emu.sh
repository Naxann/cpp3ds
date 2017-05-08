#!/bin/bash

LIBS_REQUIRED=("libsfml" "libglew" "libQt5Gui" "libopenal" "libjpeg" "libpng", "libfreetype", "libfaad", "libvorbis", "libssl")
LIBS_PKG_EQUIVALENT=("libsfml-dev", "libglew-dev", "qt5-default", "libopenal-dev", "libjpeg-dev", "libpng-dev", "libfreetype6-dev", "libvorbis-dev", "libfaad-dev", "libssl-dev")
LIBS_YUM_EQUIVALENT=()
COMMANDS_REQUIRED=("make" "cmake" "patch" "pkg-config")

FMT_DOWNLOAD=https://github.com/fmtlib/fmt/archive/3.0.1.tar.gz

download() {
	wget -q --show-progress --no-check-certificate -O "$1" "$2"
}

########################################
# Building libfmt with patch and putting it in cpp3ds
########################################

DIR_SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PATH_DOWNLOAD=$(mktemp)
DIR_COMPILATION=$(mktemp -d)

download $PATH_DOWNLOAD $FMT_DOWNLOAD
tar -xaf $PATH_DOWNLOAD -C $DIR_COMPILATION --strip 1
cd $DIR_COMPILATION
patch -Np1 -i $DIR_SOURCE/fmt.patch
cmake -DCMAKE_INSTALL_PREFIX="$CPP3DS/host" -DFMT_TEST=OFF .
make install VERBOSE=1
