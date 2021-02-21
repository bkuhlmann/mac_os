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

# Answers current CPU.
# Parameters: None.
get_cpu() {
  printf "%s" "$(system_profiler SPHardwareDataType | awk '/Chip/ {print $3}')"
}
export -f get_cpu

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
  local file_extension=$(get_extension "$file_name")

  # Dynamically build the install path based on file extension.
  case $file_extension in
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
