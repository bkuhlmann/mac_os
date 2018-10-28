#! /usr/bin/env bash

# Defines verification/validation functions.

# Checks for missing Homebrew formulas.
verify_homebrew_formulas() {
  printf "Checking Homebrew formulas...\n"

  local applications="$(brew list)"

  while read line; do
    # Skip blank or comment lines.
    if [[ "$line" == "brew install"* ]]; then
      local application=$(printf "$line" | awk '{print $3}')

      # Exception: "gpg" is the binary but is listed as "gnugp".
      if [[ "$application" == "gpg" ]]; then
        application="gnupg"
      fi

      # Exception: "hg" is the binary but is listed as "mercurial".
      if [[ "$application" == "hg" ]]; then
        application="mercurial"
      fi

      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_homebrew_formulas"

  printf "Homebrew formula check complete.\n"
}
export -f verify_homebrew_formulas

# Checks for missing Homebrew casks.
verify_homebrew_casks() {
  printf "\nChecking Homebrew casks...\n"

  local applications="$(brew cask list)"

  while read line; do
    # Skip blank or comment lines.
    if [[ "$line" == "brew cask install"* ]]; then
      local application=$(printf "$line" | awk '{print $4}')

      # Skip: Only necessary for the purpose of licensing system preference.
      if [[ "$application" == "witch" ]]; then
        continue
      fi

      # Skip: Bug with Homebrew Cask as these apps never show up as installed.
      if [[ "$application" == "skitch" || "$application" == "openemu" ]]; then
        continue
      fi

      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_homebrew_casks"

  printf "Homebrew cask check complete.\n"
}
export -f verify_homebrew_casks

# Checks for missing App Store applications.
verify_app_store_applications() {
  printf "\nChecking App Store applications...\n"

  local applications="$(mas list)"

  while read line; do
    # Skip blank or comment lines.
    if [[ "$line" == "mas install"* ]]; then
      local application=$(printf "$line" | awk '{print $3}')
      verify_listed_application "$application" "${applications[*]}"
    fi
  done < "$MAC_OS_CONFIG_PATH/bin/install_app_store"

  printf "App Store check complete.\n"
}
export -f verify_app_store_applications

# Verifies listed application exists.
# Parameters: $1 (required) - The current application, $2 (required) - The application list.
verify_listed_application() {
  local application="$1"
  local applications="$2"

  if [[ "${applications[*]}" != *"$application"* ]]; then
    printf " - Missing: $application\n"
  fi
}
export -f verify_listed_application

# Checks for missing applications suffixed by "APP_NAME" as defined in settings.sh.
verify_applications() {
  printf "\nChecking application software...\n"

  # Only use environment keys that end with "APP_NAME".
  local file_names=$(set | awk -F "=" '{print $1}' | grep ".*APP_NAME")

  # For each application name, check to see if the application is installed. Otherwise, skip.
  for name in $file_names; do
    # Pass the key value to verfication.
    verify_application "${!name}"
  done

  printf "Application software check complete.\n"
}
export -f verify_applications

# Verifies application exists.
# Parameters: $1 (required) - The file name.
verify_application() {
  local file_name="$1"

  # Display the missing install if not found.
  local install_path=$(get_install_path "$file_name")

  if [[ ! -e "$install_path" ]]; then
    printf " - Missing: $file_name\n"
  fi
}
export -f verify_application

# Checks for missing extensions suffixed by "EXTENSION_PATH" as defined in settings.sh.
verify_extensions() {
  printf "\nChecking application extensions...\n"

  # Only use environment keys that end with "EXTENSION_PATH".
  local extensions=$(set | awk -F "=" '{print $1}' | grep ".*EXTENSION_PATH")

  # For each extension, check to see if the extension is installed. Otherwise, skip.
  for extension in $extensions; do
    # Evaluate/extract the key (extension) value and pass it on for verfication.
    verify_path "${!extension}"
  done

  printf "Application extension check complete.\n"
}
export -f verify_extensions

# Verifies path exists.
# Parameters: $1 (required) - The path.
verify_path() {
  local path="$1"

  # Display the missing path if not found.
  if [[ ! -e "$path" ]]; then
    printf " - Missing: $path\n"
  fi
}
export -f verify_path
