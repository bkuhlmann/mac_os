#! /usr/bin/env bash

# Defines general utility functions.

# Label: Caffeinate Machine
# Description: Keep machine running for a very long time.
caffeinate_machine() {
  if [[ -n "$(pgrep -x caffeinate)" ]]; then
    printf "Machine is already caffeinated!\n"
  else
    caffeinate -s -u -d -i -t 3153600000 > /dev/null &
    printf "Machine caffeinated.\n"
  fi
}
export -f caffeinate_machine

# Label: Clean Work Path
# Description: Clean work path of artifacts.
clean_work_path() {
  rm -rf "$MAC_OS_WORK_PATH"
}
export -f clean_work_path

# Label: Get Basename
# Description: Answer file or directory basename.
# Parameters: $1 (required): Path.
get_basename() {
  printf "%s" "${1##*/}"
}
export -f get_basename

# Label: Get Extension
# Description: Answer file extension without dot prefix.
# Parameters: $1 (required): Path.
get_extension() {
  local name=""
  local extension="${1##*.}"

  name=$(get_basename "$1")

  if [[ "$name" == "$extension" ]]; then
    printf ''
  else
    printf "%s" "$extension"
  fi
}
export -f get_extension

# Label: Get Homebrew Root
# Description: Answer Homebrew root path.
get_homebrew_root() {
  if [[ "$(/usr/bin/arch)" == "arm64" ]]; then
    printf "%s" "/opt/homebrew"
  else
    printf "%s" "/usr/local/Homebrew"
  fi
}
export -f get_homebrew_root

# Label: Get Homebrew Bin Root
# Description: Answer Homebrew binary root path.
get_homebrew_bin_root() {
  if [[ "$(/usr/bin/arch)" == "arm64" ]]; then
    printf "%s" "/opt/homebrew/bin"
  else
    printf "%s" "/usr/local/bin"
  fi
}
export -f get_homebrew_bin_root

# Label: Get Install Path
# Description: Answer full install path (including file name).
# Parameters: $1 (required): Path.
get_install_path() {
  local file_name="$1"
  local install_path=""

  install_path=$(get_install_root "$file_name")

  printf "%s" "$install_path/$file_name"
}
export -f get_install_path

# Label: Get Install Root
# Description: Answer root install path.
# Parameters: $1 (required): Path.
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

# Label: Check Mac App Store Install
# Description: Check Mac App Store (mas) CLI has been installed.
check_mas_install() {
  if ! command -v mas > /dev/null; then
    printf "%s\n" "ERROR: Mac App Store (mas) CLI can't be found."
    printf "%s\n" "       Please ensure mas (i.e. brew install mas) is installed."
    exit 1
  fi
}
export -f check_mas_install

# Label: Configure Environment
# Description: Configure shell and ensure PATH is properly configured.
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
