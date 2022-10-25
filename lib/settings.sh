#! /usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
IFS=$'\n\t'

export MAC_OS_BOOT_DISK_CREATOR="/Applications/Install macOS Ventura.app/Contents/Resources/createinstallmedia"
export MAC_OS_BOOT_DISK_PATH="/Volumes/Untitled"
export MAC_OS_WORK_PATH=/tmp/downloads
export MAC_OS_CONFIG_PATH="../mac_os-config"
