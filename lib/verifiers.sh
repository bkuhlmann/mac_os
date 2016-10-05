#! /bin/bash

# DESCRIPTION
# Defines verification/validation functions.

# Verifies Homebrew software exists.
# Parameters:
# $1 = The file name.
verify_homebrew() {
  local application="$1"
  local applications="$2"

  if [[ "${applications[*]}" != *"$application"* ]]; then
    printf " - Missing: $application\n"
  fi
}
export -f verify_homebrew

# Checks for missing Homebrew software.
verify_homebrews() {
  printf "Checking Homebrew software...\n"

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

      verify_homebrew "$application" "${applications[*]}"
    fi
  done < "$PWD/scripts/homebrew.sh"

  printf "Homebrew check complete.\n"
}
export -f verify_homebrews

# Verifies application exists.
# Parameters:
# $1 = The file name.
verify_application() {
  local file_name="$1"

  # Display the missing install if not found.
  local install_path=$(get_install_path "$file_name")

  if [[ ! -e "$install_path" ]]; then
    printf " - Missing: $file_name\n"
  fi
}
export -f verify_application

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

# Verifies path exists.
# Parameters:
# $1 = The path.
verify_path() {
  local path="$1"

  # Display the missing path if not found.
  if [[ ! -e "$path" ]]; then
    printf " - Missing: $path\n"
  fi
}
export -f verify_path

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
