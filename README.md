<p align="center">
  <img src="mac_os.png" alt="MacOS Icon"/>
</p>

# macOS

[![Circle CI Status](https://circleci.com/gh/bkuhlmann/mac_os.svg?style=svg)](https://circleci.com/gh/bkuhlmann/mac_os)

Shell scripts for automated macOS machine setup.

This project is a framework for automating the setup of a macOS machine. In order to illustrate the
potential of what this project can do, please see the companion
[macOS Config](https://github.com/bkuhlmann/mac_os-config) project for details. The *macOS Config*
project is an opinionated configuration which meets the needs of my development environment but is
also meant to serve as an example and guide for building your own personalized setup. Here is how
the two projects are meant to be used:

- **macOS** (this project) - The foundation framework for building customizated macOS machine
  setups.
- **[macOS Configuration](https://github.com/bkuhlmann/mac_os-config)** - The layer on top of this
  *macOS* project which defines a custom machine setup and base implementation. The project is meant
  to be forked for as many custom machine setups as needed.

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Features](#features)
  - [Screencast](#screencast)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Usage](#usage)
    - [Boot Disk](#boot-disk)
    - [Startup Security Utility](#startup-security-utility)
    - [Customization](#customization)
  - [Troubleshooting](#troubleshooting)
  - [Versioning](#versioning)
  - [Code of Conduct](#code-of-conduct)
  - [Contributions](#contributions)
  - [License](#license)
  - [History](#history)
  - [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Features

- Provides a command line interface, written in Bash, with no additional dependencies for
  installation and management of a macOS machine.
- Supports macOS boot disk creation for fresh install of operating system.
- Downloads and installs [Xcode Command Line Tools](https://developer.apple.com/xcode).
- Downloads, installs, and configures [Homebrew Formulas](http://brew.sh).
- Downloads, installs, and configures [Homebrew Casks](https://caskroom.github.io).
- Downloads, installs, and configures
  [App Store](http://www.apple.com/macosx/whats-new/app-store.html) software.
- Downloads, installs, and configures non-App Store software applications.
- Downloads, installs, and configures software application extensions.
- Applies basic and default software settings.
- Sets up and configures installed software for use.
- Supports restoration of machine backups.

## Screencast

[![asciicast](https://asciinema.org/a/278158.svg)](https://asciinema.org/a/278158)

## Requirements

1. [macOS Catalina](https://www.apple.com/macos/catalina) (with latest software updates applied)
1. [Xcode](https://developer.apple.com/xcode) (with accepted license agreement)

## Setup

Open a terminal window and execute one of the following setup sequences depending on your version
preference:

Current Version (stable):

    git clone https://github.com/bkuhlmann/mac_os.git
    cd mac_os
    git checkout 8.0.1

Master Version (unstable):

    git clone https://github.com/bkuhlmann/mac_os.git
    cd mac_os

## Usage

Run the following:

    bin/run

You will be presented with the following options (listed in order of use):

    Boot:
       B:  Create boot disk.
    Install:
       b:  Apply basic settings.
       t:  Install development tools.
      hf:  Install Homebrew Formulas.
      hc:  Install Homebrew Casks.
       m:  Install Mac App Store software.
       a:  Install application software.
       x:  Install application software extensions.
       d:  Apply default settings.
       s:  Setup installed software.
       i:  Install everything (i.e. executes all install options).
    Restore:
       R:  Restore settings from backup.
    Manage:
       c:  Check status of managed software.
       C:  Caffeinate machine.
      ua:  Uninstall application software.
      ux:  Uninstall application software extension.
      ra:  Reinstall application software.
      rx:  Reinstall application software extension.
       w:  Clean work (temp) directory.
       q:  Quit/Exit.

Choose option `i` to run a full install or select a specific option to run a single action. Each
option is designed to be re-run if necessary. This can also be handy for performing upgrades,
re-running a missing/failed install, etc.

The option prompt can be skipped by passing the desired option directly to the `bin/run` script. For
example, executing `bin/run i` will execute the full install process.

The machine should be rebooted after all install tasks have completed to ensure all settings have
been loaded.

It is recommended that the `mac_os` project directory not be deleted and kept on the local machine
in order to manage installed software and benefit from future upgrades.

### Boot Disk

When attempting to create a boot disk via `bin/run B`, you'll be presented with the following
documentation (provided here for reference):

    macOS Boot Disk Tips
      - Use a USB drive (8GB or higher).
      - Use Disk Utility to format the USB drive as "Mac OS Extended (Journaled)".
      - Use Disk Utility to label the USB drive as "Untitled".

    macOS Boot Disk Usage:
      1. Insert the USB boot disk into the machine to be upgraded.
      2. Reboot the machine.
      3. Hold down the OPTION key before the Apple logo appears.
      4. Select the USB boot disk from the menu.
      5. Use Disk Utility to format the machine's drive as "APFS (Encrypted)".
      6. Install the new operating system.

    macOS Reinstall:
      1. Click the Apple icon from the operating system main menu.
      2. Select the "Restart..." menu option.
      3. Hold down the COMMAND+R keys before the Apple logo appears.
      4. Wait for the macOS installer to load from the recovery partition.
      5. Use the dialog options to launch Disk Utility, reinstall the system, etc.

Depending on your security settings, you might need to use the Startup Security Utility before using
the Boot Disk (see below).

### [Startup Security Utility](https://support.apple.com/en-us/HT208198)

With newer hardware, you should be running with the Apple T2 Security Chip (found via  → About This
Mac → Overview → System Report → Controller). In order to boot your machine using the Boot Disk,
you'll need to *temporarily* disable the default security settings as follows:

- Turn on or restart your Mac, then press and hold `COMMAND + R` immediately after seeing the Apple
  logo.
- Select Utilities → Startup Security Utility from the main menu.
- Click "Turn Off Firmware Password".
- Select "Secure Boot: No Security".
- Select "External Boot: Allow booting from external media".
- Quit the utility and restart the machine.

You'll now be able to boot your system with the Boot Disk (see above).

After the new operating system has been installed via the Boot Disk, *ensure you return to the
Startup Security Utility and re-enable the following settings*:

- Click "Turn On Firmware Password".
- Select "Secure Boot: Full Security".
- Select "External Boot: Disallow booting from external or removable media".

### Customization

All executable scripts can be found in the `bin` folder:

- `bin/apply_basic_settings`: Applies basic, initial, settings for setting up a machine. *Can be
  customized.*
- `bin/apply_default_settings`: Applies useful system and application defaults. *Can be customized.*
- `bin/create_boot_disk`: Creates macOS boot disk.
- `bin/install_app_store`: Installs macOS, GUI-based, App Store applications. *Can be customized.*
- `bin/install_applications`: Installs macOS, GUI-based, non-App Store applications. *Can be
  customized.*
- `bin/install_dev_tools`: Installs macOS development tools required by Homebrew.
- `bin/install_extensions`: Installs macOS application extensions and add-ons. *Can be customized.*
- `bin/install_homebrew_casks`: Installs Homebrew Formulas. *Can be customized.*
- `bin/install_homebrew_formulas`: Installs Homebrew Casks. *Can be customized.*
- `bin/restore_backup`: Restores system/application settings from backup image. *Can be customized.*
- `bin/run`: The main script and interface for macOS setup.
- `bin/setup_software`: Configures and launches (if necessary) installed software. *Can be
  customized.*

The `lib` folder provides the base framework for installing, re-installing, and uninstalling
software. Everything provided via the [macOS Config](https://github.com/bkuhlmann/mac_os-config)
project is built upon the functions found in the `lib` folder. See the
[macOS Config](https://github.com/bkuhlmann/mac_os-config) project for further details.

  - `lib/settings.sh`: Defines global settings for software applications, extensions, etc.

## Troubleshooting

- When using the boot disk, you might experience a situation where you see a black screen with a
  white circle and diagonal line running through it. This means macOS lost or can't find the boot
  disk for some reason. To correct this, shut down and boot up the system again while holding down
  the `OPTION+COMMAND+R+P` keys simultaneously. You might want to wait for the system boot sound to
  happen a few times before releasing the keys. This will clear the system NVRAM/PRAM. At this point
  you can shut down and restart the system following the boot disk instructions (the boot disk will
  be recognized now).
- Sometimes, when installing XCode development tools (i.e. the `t` option), not all of the macOS
  headers will be installed. This can cause issues with compiling and building native packages. For
  example: `fatal error: 'stdio.h' file not found`. This can happen due to an intermittent bug with
  the XCode installer. To fix this, you'll need to install this package:
  `/Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg`. Depending on
  your system, the version might differ, so look for a `*.pkg` in the
  `/Library/Developer/CommandLineTools/Packages` folder.

## Versioning

Read [Semantic Versioning](https://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

## Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

## Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

Copyright 2016 [Alchemists](https://www.alchemists.io).
Read [LICENSE](LICENSE.md) for details.

## History

Read [CHANGES](CHANGES.md) for details.
Built with [Bashsmith](https://github.com/bkuhlmann/bashsmith).

## Credits

Developed by [Brooke Kuhlmann](https://www.alchemists.io) at
[Alchemists](https://www.alchemists.io).
