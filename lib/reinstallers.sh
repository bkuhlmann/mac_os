#! /usr/bin/env bash

# Defines reinstall functions.

# Reinstall application.
reinstall_application() {
  uninstall_application
  bin/install_applications
}
export -f reinstall_application

# Reinstall extension.
reinstall_extension() {
  uninstall_extension
  bin/install_extensions
}
export -f reinstall_extension
