#! /bin/bash

# DESCRIPTION
# Defines global settings.

# SETTINGS
# General
set -o nounset
set -o errexit
set -o pipefail
IFS=$'\n\t'

# Globals
export MAC_OS_BOOT_DISK_CREATOR="/Applications/Install macOS Sierra.app/Contents/Resources/createinstallmedia"
export MAC_OS_BOOT_DISK_PATH="/Volumes/Untitled"
export MAC_OS_INSTALLER_PATH="/Applications/Install macOS Sierra.app"
export MAC_OS_WORK_PATH=/tmp/downloads
export MAC_OS_CONFIG_PATH="../mac_os-config"

# Java
export JAVA_VOLUME_NAME="JDK 8 Update 101"
export JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-macosx-x64.dmg"
