#! /usr/bin/env bash

# DESCRIPTION
# Defines software restore functions.

# Label: Restore Preference
# Description: Restores an application preference.
# Parameters: $1 (required) - The backup volume root path, $2 (required) - The preference file.
restore_preference() {
  local backup_root="$1"
  local preference_file="$2"
  local backup_path="$backup_root/Users/$USER/Library/Preferences/$preference_file"
  local restore_root="$HOME/Library/Preferences"

  cp -p "$backup_path" "$restore_root"
}
export -f restore_preference

# Label: Restore Application Support
# Description: Restores application support files.
# Parameters: $1 (required) - The backup volume root path, $2 required - The application name.
restore_app_support() {
  local backup_root="$1"
  local app_name="$2"
  local backup_path="$backup_root/Users/$USER/Library/Application Support/$app_name"
  local restore_path="$HOME/Library/Application Support"

  mkdir -p "$restore_path"
  cp -pR "$backup_path" "$restore_path"
}
export -f restore_app_support
