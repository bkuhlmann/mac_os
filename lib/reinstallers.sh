#! /usr/bin/env bash

# DESCRIPTION
# Defines reinstall functions.

# Reinstall application.
reinstall_application() {
  uninstall_application
  scripts/applications.sh
}
export -f reinstall_application

# Reinstall extension.
reinstall_extension() {
  uninstall_extension
  scripts/extensions.sh
}
export -f reinstall_extension
