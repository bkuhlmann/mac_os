#! /usr/bin/env bash

# Defines software installer functions.

# Downloads remote file to local disk.
# Parameters: $1 (required) - URL, $2 (required) - File name, $3 (optional) - HTTP header.
download_file() {
  local url="$1"
  local file_name="$2"
  local http_header="$3"

  printf "%s\n" "Downloading $1..."
  clean_work_path
  mkdir "$MAC_OS_WORK_PATH"

  curl --header "$http_header" \
       --location \
       --retry 3 \
       --retry-delay 5 \
       --fail \
       --silent \
       --show-error \
       "$url" >> "$MAC_OS_WORK_PATH/$file_name"
}
export -f download_file

# Installs an application.
# Parameters: $1 (required) - Application source path, $2 (required) - Application name.
install_app() {
  local install_root=$(get_install_root "$2")
  local file_extension=$(get_extension "$2")

  printf "Installing: $install_root/$2...\n"

  case $file_extension in
    '')
      cp -a "$1/$2" "$install_root";;
    'app')
      cp -a "$1/$2" "$install_root";;
    'prefPane')
      sudo cp -pR "$1/$2" "$install_root";;
    'qlgenerator')
      sudo cp -pR "$1/$2" "$install_root" && qlmanage -r;;
    *)
      printf "ERROR: Unknown file extension: $file_extension.\n"
  esac
}
export -f install_app

# Installs an application via a DMG file.
# Parameters: $1 (required) - URL, $2 (required) - Mount path, $3 (required) - Application name.
install_dmg_app() {
  local url="$1"
  local mount_point="/Volumes/$2"
  local app_name="$3"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.dmg"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"
    mount_image "$MAC_OS_WORK_PATH/$work_file"
    install_app "$mount_point" "$app_name"
    unmount_image "$mount_point"
    verify_application "$app_name"
  fi
}
export -f install_dmg_app

# Installs a package via a DMG file.
# Parameters: $1 (required) - URL, $2 (required) - Mount path, $3 (required) - Application name.
install_dmg_pkg() {
  local url="$1"
  local mount_point="/Volumes/$2"
  local app_name="$3"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.dmg"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"
    mount_image "$MAC_OS_WORK_PATH/$work_file"
    install_pkg "$mount_point" "$app_name"
    unmount_image "$mount_point"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}
export -f install_dmg_pkg

# Installs a single file.
# Parameters: $1 (required) - URL, $2 (required) - Install path.
install_file() {
  local file_url="$1"
  local file_name=$(get_basename "$1")
  local install_path="$2"

  if [[ ! -e "$install_path" ]]; then
    download_file "$file_url" "$file_name"
    mkdir -p $(dirname "$install_path")
    mv "$MAC_OS_WORK_PATH/$file_name" "$install_path"
    printf "Installed: $file_name.\n"
    verify_path "$install_path"
  fi
}
export -f install_file

# Installs application code from a Git repository.
# Parameters: $1 (required) - Repository URL, $2 (required) - Install path, $3 (optional) - Git clone options.
install_git_app() {
  local repository_url="$1"
  local app_name=$(get_basename "$2")
  local install_path="$2"
  local options="--quiet"

  if [[ -n "$3" ]]; then
    local options="$options $3"
  fi

  if [[ ! -e "$install_path" ]]; then
    printf "Installing: $install_path/$app_name...\n"
    git clone $options "$repository_url" "$install_path"
    printf "Installed: $app_name.\n"
    verify_path "$install_path"
  fi
}
export -f install_git_app

# Installs settings from a Git repository.
# Parameters: $1 (required) - Repository URL, $2 (required) - Repository version, $3 (required) - Project directory, $4 (required) - Script to run (including any arguments).
install_git_project() {
  local repo_url="$1"
  local repo_version="$2"
  local project_dir="$3"
  local script="$4"

  git clone "$repo_url"
  (
    cd "$project_dir"
    git -c advice.detachedHead=false checkout "$repo_version"
    eval "$script"
  )
  rm -rf "$project_dir"
}
export -f install_git_project

# Installs Homebrew.
# Parameters: None.
install_homebrew() {
  if ! command -v brew > /dev/null; then
    /bin/bash -c "$(curl --location --fail --silent --show-error https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "eval \"($(get_homebrew_bin_root)/brew shellenv)\"" > $HOME/.zprofile
    eval "$($(get_homebrew_bin_root)/brew shellenv)"
  fi
}
export -f install_homebrew

# Installs a package via a zip file.
# Parameters: $1 (required) - URL, $2 (required) - Application name.
install_bare_pkg() {
  local url="$1"
  local app_name="$2"
  local install_path=$(get_install_path "$app_name")
  local work_file="$app_name.pkg"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"
    install_pkg "$MAC_OS_WORK_PATH" "$app_name"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}
export -f install_bare_pkg

# Installs a package.
# Parameters: $1 (required) - Package source path, $2 (required) - Application name.
install_pkg() {
  local install_root=$(get_install_root "$2")

  printf "Installing: $install_root/$2...\n"
  local package=$(sudo find "$1" -maxdepth 1 -type f -name "*.pkg" -o -name "*.mpkg")
  sudo installer -pkg "$package" -target /
}
export -f install_pkg

# Installs program (single file).
# Parameters: $1 (required) - URL, $2 (required) - Program name.
install_program() {
  local url="$1"
  local program_name="$2"
  local install_path=$(get_install_path "$program_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$program_name"
    mv "$MAC_OS_WORK_PATH/$program_name" "$install_path"
    chmod 755 "$install_path"
    printf "Installed: $program_name.\n"
    verify_application "$program_name"
  fi
}
export -f install_program

# Installs Node.
# Parameters: None.
install_node() {
  if [[ ! -x "$(command -v node)" ]]; then
    "$(get_homebrew_bin_root)/fnm" install --latest
  fi
}
export -f install_node

# Installs Ruby.
# Parameters: None.
install_ruby() {
  local version="$(cat $HOME/.ruby-version | tr -d '\n')"

  if [[ ! -x "$(command -v ruby)" && -n $(ruby --version | grep --quiet "$version") ]]; then
    "$(get_homebrew_bin_root)"/frum install "$version" \
                                            --with-openssl-dir="$(brew --prefix openssl)" \
                                            --enable-shared \
                                            --disable-silent-rules
    "$(get_homebrew_bin_root)"/frum local "$version"
  fi
}
export -f install_ruby

# Installs Rust.
# Parameters: None.
install_rust() {
  if ! command -v cargo > /dev/null; then
    curl --proto "=https" --tlsv1.2 --fail --silent --show-error https://sh.rustup.rs | sh
  fi
}
export -f install_rust

# Installs an application via a tar file.
# Parameters: $1 (required) - URL, $2 (required) - Application name, $3 (required) - Decompress options.
install_tar_app() {
  local url="$1"
  local app_name="$2"
  local options="$3"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.tar"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      tar "$options" "$work_file"
    )

    install_app "$MAC_OS_WORK_PATH" "$app_name"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}
export -f install_tar_app

# Installs an application via a zip file.
# Parameters: $1 (required) - URL, $2 (required) - Application name.
install_zip_app() {
  local url="$1"
  local app_name="$2"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.zip"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      unzip -q "$work_file"
      find . -type d -name "$app_name" -print -exec cp -pR {} . > /dev/null 2>&1 \;
    )

    install_app "$MAC_OS_WORK_PATH" "$app_name"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}
export -f install_zip_app

# Installs a package via a zip file.
# Parameters: $1 (required) - URL, $2 (required) - Application name.
install_zip_pkg() {
  local url="$1"
  local app_name="$2"
  local install_path=$(get_install_path "$app_name")
  local work_file="download.zip"

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      unzip -q "$work_file"
    )

    install_pkg "$MAC_OS_WORK_PATH" "$app_name"
    printf "Installed: $app_name.\n"
    verify_application "$app_name"
  fi
}
export -f install_zip_pkg

# Mounts a disk image.
# Parameters: $1 (required) - Image path.
mount_image() {
  printf "Mounting image...\n"
  hdiutil attach -quiet -nobrowse -noautoopen "$1"
}
export -f mount_image

# Unmounts a disk image.
# Parameters: $1 (required) - Mount path.
unmount_image() {
  printf "Unmounting image...\n"
  hdiutil detach -force "$1"
}
export -f unmount_image
