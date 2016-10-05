#! /bin/bash

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
      "$MAC_OS_CONFIG_PATH/bin/apply_basic_settings";;
    't')
      bin/install_dev_tools;;
    'h')
      "$MAC_OS_CONFIG_PATH/bin/install_homebrew";;
    'a')
      "$MAC_OS_CONFIG_PATH/bin/install_applications";;
    'x')
      "$MAC_OS_CONFIG_PATH/bin/install_extensions";;
    'd')
      "$MAC_OS_CONFIG_PATH/bin/apply_default_settings";;
    's')
      "$MAC_OS_CONFIG_PATH/bin/setup_software";;
    'i')
      caffeinate_machine
      "$MAC_OS_CONFIG_PATH/bin/apply_basic_settings"
      bin/install_dev_tools
      "$MAC_OS_CONFIG_PATH/bin/install_homebrew"
      "$MAC_OS_CONFIG_PATH/bin/install_applications"
      "$MAC_OS_CONFIG_PATH/bin/install_extensions"
      "$MAC_OS_CONFIG_PATH/bin/apply_default_settings"
      "$MAC_OS_CONFIG_PATH/bin/setup_software"
      clean_work_path;;
    'R')
      "$MAC_OS_CONFIG_PATH/bin/restore_backup";;
    'c')
      verify_homebrews
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
