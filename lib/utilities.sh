#! /usr/bin/env bash

# Defines general utility functions.

# Caffeinate machine.
caffeinate_machine() {
  local pid=$(pgrep -x caffeinate)

  if [[ -n "$pid" ]]; then
    printf "Machine is already caffeinated!\n"
  else
    caffeinate -s -u -d -i -t 3153600000 > /dev/null &
    printf "Machine caffeinated.\n"
  fi
}
export -f caffeinate_machine

# Cleans work path for temporary processing of installs.
clean_work_path() {
  rm -rf "$MAC_OS_WORK_PATH"
}
export -f clean_work_path

# Answers the file or directory basename.
# Parameters: $1 (required) - The file path.
get_basename() {
  printf "${1##*/}" # Answers file or directory name.
}
export -f get_basename

# Answers the file extension.
# Parameters: $1 (required) - The file name.
get_extension() {
  local name=$(get_basename "$1")
  local extension="${1##*.}" # Excludes dot.

  if [[ "$name" == "$extension" ]]; then
    printf ''
  else
    printf "$extension"
  fi
}
export -f get_extension

# Answers Homebrew root path.
# Parameters: None.
get_homebrew_root() {
  if [[ "$(/usr/bin/arch)" == "arm64" ]]; then
    printf "%s" "/opt/homebrew"
  else
    printf "%s" "/usr/local/Homebrew"
  fi
}
export -f get_homebrew_root

# Answers Homebrew binary root path.
# Parameters: None.
get_homebrew_bin_root() {
  if [[ "$(/usr/bin/arch)" == "arm64" ]]; then
    printf "%s" "/opt/homebrew/bin"
  else
    printf "%s" "/usr/local/bin"
  fi
}
export -f get_homebrew_bin_root

# Answers the full install path (including file name) for file name.
# Parameters: $1 (required) - The file name.
get_install_path() {
  local file_name="$1"
  local install_path=$(get_install_root "$file_name")
  printf "$install_path/$file_name"
}
export -f get_install_path

# Answers the root install path for file name.
# Parameters: $1 (required) - The file name.
get_install_root() {
  local file_name="$1"

  case $(get_extension "$file_name") in
    '')
      printf "/usr/local/bin";;
    'app')
      printf "/Applications";;
    'prefPane')
      printf "/Library/PreferencePanes";;
    'qlgenerator')
      printf "/Library/QuickLook";;
    *)
      printf "/tmp/unknown";;
  esac
}
export -f get_install_root

# Checks Mac App Store (mas) CLI has been installed and exits if otherwise.
# Parameters: None.
check_mas_install() {
  if ! command -v mas > /dev/null; then
    printf "%s\n" "ERROR: Mac App Store (mas) CLI can't be found."
    printf "%s\n" "       Please ensure Homebrew and mas (i.e. brew install mas) have been installed."
    exit 1
  fi
}
export -f check_mas_install

# Configures shell for new machines and ensures PATH is properly configured for running scripts.
# Parameters: None.
configure_environment() {
  if [[ ! -s "$HOME/.bash_profile" ]]; then
    printf "%s\n" "if [ -f ~/.bashrc ]; then . ~/.bashrc; fi" > "$HOME/.bash_profile"
  fi

  if [[ ! -s "$HOME/.bashrc" ]]; then
    printf "%s\n" 'export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"' > "$HOME/.bashrc"
    source "$HOME/.bashrc"
  fi
}
export -f configure_environment
