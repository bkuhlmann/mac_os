#! /usr/bin/env bash

# Defines verification/validation functions.

# Label: Verify App Store Applications
# Description: Check for missing App Store applications.
verify_app_store_applications() {
  local applications=""

  printf "\n%s\n" "Checking App Store applications..."
  applications="$(mas list)"

  while read line; do
    if [[ "$line" == "mas install"* ]]; then
      application=$(printf "$line" | awk '{print $3}')
      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_app_store"

  printf "%s\n" "App Store check complete."
}
export -f verify_app_store_applications

# Label: Verify Application
# Description: Verify application exists.
# Parameters: $1 (required): File name.
verify_application() {
  local file_name="$1"

  if [[ ! -e "$(get_install_path "$file_name")" ]]; then
    printf "%s\n" " - Missing: $file_name"
  fi
}
export -f verify_application

# Label: Verify Applications
# Description: Check for missing applications suffixed by "APP_NAME" as defined in settings.
verify_applications() {
  local file_names=""

  printf "\n%s\n" "Checking application software..."

  # Only use environment keys that end with "APP_NAME".
  file_names=$(set | awk -F "=" '{print $1}' | grep ".*APP_NAME")

  # For each application name, check to see if the application is installed. Otherwise, skip.
  for name in $file_names; do
    verify_application "${!name}"
  done

  printf "%s\n" "Application software check complete."
}
export -f verify_applications

# Label: Verify Extensions
# Description: Check for missing extensions suffixed by "EXTENSION_PATH" as defined in settings.
verify_extensions() {
  local extensions=""

  printf "\n%s\n" "Checking application extensions..."

  # Only use environment keys that end with "EXTENSION_PATH".
  extensions=$(set | awk -F "=" '{print $1}' | grep ".*EXTENSION_PATH")

  # For each extension, check to see if the extension is installed. Otherwise, skip.
  for extension in $extensions; do
    # Evaluate/extract the key (extension) value and pass it on for verfication.
    verify_path "${!extension}"
  done

  printf "%s\n" "Application extension check complete."
}
export -f verify_extensions

# Label: Verify Homebrew Casks
# Description: Check for missing Homebrew casks.
verify_homebrew_casks() {
  local applications=""

  printf "\nChecking Homebrew casks...\n"

  applications="$(brew list --casks)"

  while read line; do
    if [[ "$line" == "brew cask install"* ]]; then
      application=$(printf "%s" "$line" | awk '{print $4}')
      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_homebrew_casks"

  printf "%s\n" "Homebrew cask check complete."
}
export -f verify_homebrew_casks

# Label: Verify Homebrew Formulas
# Description: Check for missing Homebrew formulas.
verify_homebrew_formulas() {
  local applications=""

  printf "Checking Homebrew formulas...\n"

  applications="$(brew list --formulae)"

  while read line; do
    if [[ "$line" == "brew install"* ]]; then
      application=$(printf "%s" "$line" | awk '{print $3}')

      # Exception: "gpg" is the binary but is listed as "gnugp".
      if [[ "$application" == "gpg" ]]; then
        application="gnupg"
      fi

      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_homebrew_formulas"

  printf "%s\n" "Homebrew formula check complete."
}
export -f verify_homebrew_formulas

# Label: Verify Listed Application
# Description: Verify listed application exists.
# Parameters: $1 (required): Current application, $2 (required): Application list.
verify_listed_application() {
  local application="$1"
  local applications="$2"

  if [[ "${applications[*]}" != *"$application"* ]]; then
    printf "%s\n" " - Missing: $application"
  fi
}
export -f verify_listed_application

# Label: Verify Path
# Description: Verify path exists.
# Parameters: $1 (required): Path.
verify_path() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    printf "%s\n" " - Missing: $path"
  fi
}
export -f verify_path

# Label: Verify Node Packages
# Description: Check for missing Node packages.
verify_node_packages() {
  printf "\n%s\n" "Checking Node packages..."

  while read line; do
    if [[ "$line" == "npm "* ]]; then
      package=$(printf "$line" | awk '{print $4}')
      packages=($(npm list --global --depth=0 | grep "$package"))

      verify_listed_application "$package" "${packages[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_node_packages"

  printf "%s\n" "Node packages check complete."
}
export -f verify_node_packages

# Label: Verify Ruby Gems
# Description: Check for missing Ruby gems.
verify_ruby_gems() {
  local gems=""

  printf "\n%s\n" "Checking Ruby gems..."

  gems="$(gem list --no-versions)"

  while read line; do
    if [[ "$line" == "gem install"* ]]; then
      gem=$(printf "%s" "$line" | awk '{print $3}')
      verify_listed_application "$gem" "${gems[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_ruby_gems"

  printf "%s\n" "Ruby gems check complete."
}
export -f verify_ruby_gems

# Label: Verify Rust Crates
# Description: Check for missing Rust crates.
verify_rust_crates() {
  local crates=""

  printf "\n%s\n" "Checking Rust crates..."

  crates="$(ls -A1 $HOME/.cargo/bin)"

  while read line; do
    if [[ "$line" == "cargo install"* ]]; then
      crate=$(printf "%s" "$line" | awk '{print $3}')
      verify_listed_application "$crate" "${crates[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_rust_crates"

  printf "%s\n" "Rust crates check complete."
}
export -f verify_rust_crates
