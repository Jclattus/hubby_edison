# Intel IoT Daemon

## Introduction

The IoT Daemon is an agent running on an edge device, that allows interaction 
with the Intel XDK IDE. It runs as an OS Service, and is responsible to perform
installation, preparation, execution, and debugging of user application.

## Installation

    npm install

## Building

    ./setup.sh [--build]

## Cross Compilation

This code is intended to work in a Linux OS (i.e. Yocto) running in a Intel Galileo, Edison, or similar 
platform. There are some considerations to take into account to build the code in, for example,
an Ubuntu system, and make it run in a Yocto image. The easiest set of steps documented at the date are:   

    # Download the latest iot-devkit-sdk from iotdk.intel.com/sdk, 3.5 shown as an example
    wget http://iotdk.intel.com/sdk/3.5/edison/iot-devkit-toolchain-linux-64bit-edison-20160606.sh

    # Make the devkit an executable file with chmod
    chmod u+x iot-devkit-toolchain-linux-64bit-edison-20160606.sh

    # Install the devkit
    ./iot-devkit-toolchain-linux-64bit-edison-20160606.sh

    # Now you need to load the proper env for cross compilation
    # in this case, the devkit has been installed globally in
    # /opt/poky-edison folder
    source /opt/poky-edison/1.7.3/environment-setup-core2-32-poky-linux
    
    # IMPORTANT! This is a temporary hack to by-pass a node-gyp error
    # TODO: Work with iot-devkit team to solve this
    # filecmp.py is required by node-gyp, but it is not present in the yocto-poky 
    # filesystem, cp it to the proper location
    cp /opt/poky-edison/1.7.3/sysroots/core2-32-poky-linux/usr/lib/python2.7/filecmp.py /opt/poky-edison/1.7.3/sysroots/x86_64-pokysdk-linux/usr/lib/python2.7/ 
    
    # Then use setup.sh to build or run the daemon
    ./setup.sh [--build]
    
## Running

You can start the daemon by executing the main.js file:

    node main.js
    
Or you can make it run as service with setup.sh:

    ./setup.sh
    
This script will install the daemon in `/opt/xdk-daemon`, configure
it as a systemd service, and use systemctl to start. 

## Contributing

Run jshint code validation prior any code upload:

    grunt jshint [--teamcity]
