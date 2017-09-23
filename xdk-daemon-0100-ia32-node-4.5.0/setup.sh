#!/bin/bash
#
# @license Copyright 2016 - 2016 Intel Corporation All Rights Reserved.
#
# The source code, information and material ("Material") contained herein is owned by Intel Corporation or its
# suppliers or licensors, and title to such Material remains with Intel Corporation or its suppliers or
# licensors. The Material contains proprietary information of Intel or its suppliers and licensors. The
# Material is protected by worldwide copyright laws and treaty provisions. No part of the Material may be used,
# copied, reproduced, modified, published, uploaded, posted, transmitted, distributed or disclosed in any way
# without Intel's prior express written permission. No license under any patent, copyright or other intellectual
# property rights in the Material is granted to or conferred upon you, either expressly, by implication,
# inducement, estoppel or otherwise. Any license under such intellectual property rights must be express and
# approved by Intel in writing.
#
# Unless otherwise agreed by Intel in writing, you may not remove or alter this notice or any other notice
# embedded in Materials by Intel or Intel's suppliers or licensors in any way.

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
DIR=$(dirname "$SCRIPT")
PRODUCT_NAME="Intel XDK Daemon"
SERVICE_NAME="xdk-daemon"
INSTALL_LOCATION="/opt"
INSTALL_FOLDER="/xdk-daemon"
APPSLOT="/node_app_slot"

# if not root, try to use sudo
if [[ `whoami` == "root" ]];
then
  SUDO=""
else
  SUDO="sudo"
fi

# installing packages globally
#$SUDO npm install -g
echo "==================================================================="
echo " Installing ${PRODUCT_NAME}"
echo "==================================================================="
echo ""
echo ""
echo " Installing modules for daemon version manager"
echo "--------------------------------------------------------------------"
$SUDO cd $DIR
$SUDO export CPLUS_INCLUDE_PATH=/usr/include/avahi-compat-libdns_sd
$SUDO npm install
echo " DONE!"

echo ""
echo " Installing modules for application daemon component"
echo "--------------------------------------------------------------------"
$SUDO cd $DIR/current
$SUDO npm install
echo " DONE!"

echo ""
echo " Installing modules for debugger agent component"
echo "--------------------------------------------------------------------"
$SUDO cd $DIR/current/node-inspector-server
$SUDO npm install
echo " DONE!"

$SUDO cd $DIR


if [[ "$1" != "build" ]]
then
  # ----------------------------------------------------------------------------
  # This code attempts to detect the MDNS technology the XDK should rely on
  MDNS_STATUS=$(systemctl is-active mdns.service)
  AVAHI_STATUS=$(systemctl is-active avahi-daemon.service)

  if [ "$MDNS_STATUS" = "active" ]
  then
    SERVICE_FILE_EXTENSTION="mdns"
    echo "MDNS Detected!"
  elif [ "$AVAHI_STATUS" = "active" ]
  then
    SERVICE_FILE_EXTENSTION="avahi"
    echo "AVAHI Detected!"
  else
    SERVICE_FILE_EXTENSTION="generic"
    echo "No MDNS solution detected!"
  fi
  # ----------------------------------------------------------------------------

  #=============================================================================
  # INSTALLATION STEPS
  #=============================================================================

  #make all needed directories
  echo "Copying main daemon to $INSTALL_LOCATION$INSTALL_FOLDER"
  $SUDO mkdir -p $INSTALL_LOCATION$INSTALL_FOLDER
  $SUDO cp -ar $DIR/* $INSTALL_LOCATION$INSTALL_FOLDER/
  $SUDO chmod 755 $INSTALL_LOCATION$INSTALL_FOLDER/xdk-daemon
  echo "DONE!"
  echo ""

  #Fill previous slot
  #echo "Archiving current daemon as previous/recovery daemon"
  #$SUDO mkdir -p $INSTALL_LOCATION$INSTALL_FOLDER/previous
  #$SUDO cp -ar $DIR/current/* $INSTALL_LOCATION$INSTALL_FOLDER/previous/
  #echo "DONE!"
  #echo ""

  #Fill default slot
  #echo "Archiving current daemon as default"
  #$SUDO mkdir -p $INSTALL_LOCATION$INSTALL_FOLDER/default
  #$SUDO cp -ar $DIR/current/* $INSTALL_LOCATION$INSTALL_FOLDER/default/
  #echo "DONE!"
  #echo ""


  #Note: APPLICATION SLOT CREATION NOW HANDLED AT START OF DAEMON
  #================================================================

  # try to add a startup script to our init system
  echo ""
  echo " Installing Service(s)"
  echo "--------------------------------------------------------------------"
  if [[ -e /lib/systemd/system/${SERVICE_NAME}.service ]]
  then
    SYSTEMD_SERVICE_PATH="/lib/systemd/system/"
  elif [[ -e /usr/lib/systemd/system/${SERVICE_NAME}.service ]]
  then
    SYSTEMD_SERVICE_PATH="/usr/lib/systemd/system/"
  elif [[ -d /usr/lib/systemd/system/ ]]
  then
    SYSTEMD_SERVICE_PATH="/usr/lib/systemd/system/"
  elif [[ -d "/lib/systemd/system/" ]]
  then
    SYSTEMD_SERVICE_PATH="/lib/systemd/system/"
  else
    SYSTEMD_SERVICE_PATH="/etc/systemd/system/"
  fi

  echo "========================================="
  echo "systemd path: $SYSTEMD_SERVICE_PATH"
  echo "========================================="


  if [[ -d "$SYSTEMD_SERVICE_PATH" ]]
  then
    ${SUDO} cp -f ./${SERVICE_NAME}-${SERVICE_FILE_EXTENSTION}.service ${SYSTEMD_SERVICE_PATH}${SERVICE_NAME}.service
    ${SUDO} chmod 755 ${SYSTEMD_SERVICE_PATH}${SERVICE_NAME}.service
    ${SUDO} systemctl enable ${SERVICE_NAME} --force
  #elif [[ -d /etc/rc5.d/ ]]
  #then
  # $SUDO cp -f ./S85xdk-daemon.sh /etc/rc5.d/
  else
    echo "ERROR: startup script not copied! (this is bad)"
  fi


  read -p "Start $PRODUCT_NAME now? (y/n)? " -n 1 -r
  echo    # (optional) move to a new line
  #if [[ ! $REPLY =~ ^[Yy]$ ]]
  echo #blank line
  if  [ "$REPLY" = "y" ]
  then
      echo "Starting $SERVICE_NAME now!"
      $SUDO systemctl daemon-reload
      $SUDO systemctl restart $SERVICE_NAME 
  else
      echo "$SERVICE_NAME not started"
      echo "Type: 'systemctl start $SERVICE_NAME' to start the $SERVICE_NAME"
  fi
  #=============================================================================
  echo #blank line
  echo "Setup complete!"
fi
echo ""
