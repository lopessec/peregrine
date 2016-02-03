#!/usr/bin/env bash

set -e

function install_deps_ubuntu_maybe () {
    # Sudo'd version of travis installation instructions
    sudo apt-get update -qq
    sudo apt-get install python-software-properties
    sudo add-apt-repository --yes ppa:kalakris/cmake
    sudo apt-get update -qq
    sudo apt-get -y install cmake \
         check \
         fftw3 \
         libfftw3-dev \
         python-pip \
         build-essential \
         python-numpy \
         python-dev \
         cython \
         python-cython \
         python-dev
    git submodule update --init
    # Build libswiftnav
    cd libswiftnav/
    mkdir -p build && cd build/
    # Build and install libswiftnav
    cmake ../
    make
    sudo make install
    cd ../python
    python setup.py build && python setup.py install
    cd ../../
    sudo pip install -r requirements.txt
    sudo python setup.py develop
}

function install_deps_debian_jessie_or_stretch () {
    # Sudo'd version of travis installation instructions
    sudo apt-get update -qq
    sudo apt-get -y install cmake \
         check \
         fftw3 \
         libfftw3-dev \
         python-pip \
         build-essential \
         python-numpy \
         python-dev \
         cython \
         python-dev
    # Build and install libswiftnav
    git submodule update --init
    cd libswiftnav/
    mkdir -p build && cd build/
    cmake ../
    make -j$(nproc)
    sudo make install
    sudo ldconfig
    # Don't think we need to build/install the libswiftnav python
    # bindings; the peregrine pip install will do that for us.
#    cd ../python
#    python setup.py build
#    sudo python setup.py install
    cd ../../
    sudo pip install -r requirements.txt
    sudo python setup.py develop
}

function install_deps_osx () {
    # TODO: Add OS X brew installation dependencies
    if [[ ! -x /usr/local/bin/brew ]]; then
        echo "You're missing Homebrew!"
        exit 1
    fi
    brew install fftw
    git submodule update --init
    # Build and install libswiftnav
    cd libswiftnav/
    mkdir -p build && cd build/
    # Build and install libswiftnav
    cmake ../
    make
    sudo make install
    cd ../python
    python setup.py build && python setup.py install
    cd ../../
    sudo pip install -r requirements.txt
    sudo python setup.py develop
}

if [[ "$OSTYPE" == "linux-"* ]]; then
    if egrep -q "Debian GNU/Linux (jessie|stretch)" /etc/issue; then
        install_deps_debian_jessie_or_stretch
    else
        install_deps_ubuntu_maybe
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_deps_osx
else
    echo "This script does not support this platform. Please file a Github issue!"
    exit 1
fi