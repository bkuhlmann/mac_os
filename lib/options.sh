#! /usr/bin/env bash

# DESCRIPTION
# Defines command line prompt options.

# Process option selection.
# Parameters:
# $1 = The option to process.
process_option() {
  case $1 in
    'B')
      bin/create_boot_disk;;
    'b')
      bin/apply_basic_settings;;
    't')
      bin/install_dev_tools;;
    'hf')
      bin/install_homebrew_formulas;;
    'hc')
      bin/install_homebrew_casks;;
    'm')
      bin/install_app_store;;
    'a')
      bin/install_applications;;
    'x')
      bin/install_extensions;;
    'd')
      bin/apply_default_settings;;
    's')
      bin/setup_software;;
    'i')
      caffeinate_machine
      bin/apply_basic_settings
      bin/install_dev_tools
      bin/install_homebrew_formulas
      bin/install_homebrew_casks
      bin/install_app_store
      bin/install_applications
      bin/install_extensions
      bin/apply_default_settings
      bin/setup_software
      clean_work_path;;
    'R')
      bin/restore_backup;;
    'c')
      verify_homebrew_formulas
      verify_homebrew_casks
      verify_app_store_applications
      verify_applications
      verify_extensions;;
    'C')
      caffeinate_machine;;
    'ua')
      uninstall_application;;
    'ux')
      uninstall_extension;;
    'ra')
      reinstall_application;;
    'rx')
      reinstall_extension;;
    'w')
      clean_work_path;;
    'q');;
    *)
      printf "ERROR: Invalid option.\n";;
  esac
}
export -f process_option
