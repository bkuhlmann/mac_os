#! /usr/bin/env bash

# Defines software installer functions.

# Label: Download File
# Description: Download remote file to local disk.
# Parameters: $1 (required): URL, $2 (required): File name, $3 (optional): HTTP header.
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

# Label: Install Application
# Description: Install an application.
# Parameters: $1 (required): Install path, $2 (required): Name.
install_app() {
  local install_path="$1"
  local name="$2"
  local install_root=""
  local file_extension=""

  install_root=$(get_install_root "$name")
  file_extension=$(get_extension "$name")

  printf "%s\n" "Installing: $install_root/$name..."

  case $file_extension in
    '')
      cp -a "$install_path/$name" "$install_root";;
    'app')
      cp -a "$install_path/$name" "$install_root";;
    'prefPane')
      sudo cp -pR "$install_path/$name" "$install_root";;
    'qlgenerator')
      sudo cp -pR "$install_path/$name" "$install_root" && qlmanage -r;;
    *)
      printf "%s\n" "ERROR: Unknown file extension: $file_extension."
  esac
}
export -f install_app

# Label: Install DMG Application
# Description: Install DMG application.
# Parameters: $1 (required): URL, $2 (required): Mount path, $3 (required): Application name.
install_dmg_app() {
  local url="$1"
  local mount_point="/Volumes/$2"
  local app_name="$3"
  local install_path=""
  local work_file="download.dmg"

  install_path=$(get_install_path "$app_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"
    mount_image "$MAC_OS_WORK_PATH/$work_file"
    install_app "$mount_point" "$app_name"
    unmount_image "$mount_point"
    verify_application "$app_name"
  fi
}
export -f install_dmg_app

# Label: Install DMG Package
# Description: Install DMG application via a package file.
# Parameters: $1 (required): URL, $2 (required): Mount path, $3 (required): Application name.
install_dmg_pkg() {
  local url="$1"
  local mount_point="/Volumes/$2"
  local app_name="$3"
  local install_path=""
  local work_file="download.dmg"

  install_path=$(get_install_path "$app_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"
    mount_image "$MAC_OS_WORK_PATH/$work_file"
    install_pkg "$mount_point" "$app_name"
    unmount_image "$mount_point"
    printf "%s\n" "Installed: $app_name."
    verify_application "$app_name"
  fi
}
export -f install_dmg_pkg

# Label: Install File
# Description: Install a single file.
# Parameters: $1 (required): URL, $2 (required): Install path.
install_file() {
  local file_url="$1"
  local file_name=""
  local install_path="$2"

  file_name=$(get_basename "$1")

  if [[ ! -e "$install_path" ]]; then
    download_file "$file_url" "$file_name"
    mkdir -p $(dirname "$install_path")
    mv "$MAC_OS_WORK_PATH/$file_name" "$install_path"
    printf "%s\n" "Installed: $file_name."
    verify_path "$install_path"
  fi
}
export -f install_file

# Label: Install Git Application
# Description: Install application from a Git repository.
# Parameters: $1 (required): URL, $2 (required): Install path, $3 (optional): Git clone options.
install_git_app() {
  local url="$1"
  local install_path="$2"
  local app_name=""
  local options="--quiet"

  app_name="$(get_basename "$2")"

  if [[ -n "$3" ]]; then
    local options="$options $3"
  fi

  if [[ ! -e "$install_path" ]]; then
    printf "%s\n" "Installing: $install_path..."
    git clone $options "$url" "$install_path"
    printf "%s\n" "Installed: $app_name."
    verify_path "$install_path"
  fi
}
export -f install_git_app

# Label: Install Git Project
# Description: Install Git project.
# Parameters: $1 (required): URL, $2 (required): Version, $3 (required): Project directory, $4 (required): Script to run (including any arguments).
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

# Label: Install Homebrew
# Description: Install and setup Homebrew.
install_homebrew() {
  if ! command -v brew > /dev/null; then
    /bin/bash -c "$(curl --location --fail --silent --show-error https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "eval \"($(get_homebrew_bin_root)/brew shellenv)\"" > "$HOME/.zprofile"
    eval "$($(get_homebrew_bin_root)/brew shellenv)"
  fi
}
export -f install_homebrew

# Label: Install Bare Package
# Description: Install a bare package.
# Parameters: $1 (required): URL, $2 (required): Application name.
install_bare_pkg() {
  local url="$1"
  local app_name="$2"
  local install_path=""
  local work_file="$app_name.pkg"

  install_path=$(get_install_path "$app_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"
    install_pkg "$MAC_OS_WORK_PATH" "$app_name"
    printf "%s\n" "Installed: $app_name."
    verify_application "$app_name"
  fi
}
export -f install_bare_pkg

# Label: Install Package
# Description: Install local package.
# Parameters: $1 (required): Package source path, $2 (required): Application name.
install_pkg() {
  local source_path="$1"
  local name="$2"
  local install_root=""
  local package=""

  install_root=$(get_install_root "$name")
  package=$(sudo find "$source_path" -maxdepth 1 -type f -name "*.pkg" -o -name "*.mpkg")

  printf "%s\n" "Installing: $install_root/$name..."
  sudo installer -pkg "$package" -target /
}
export -f install_pkg

# Label: Install Program
# Description: Installs program without any packaging.
# Parameters: $1 (required): URL, $2 (required): Name.
install_program() {
  local url="$1"
  local program_name="$2"
  local install_path=""

  install_path=$(get_install_path "$program_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$program_name"
    mv "$MAC_OS_WORK_PATH/$program_name" "$install_path"
    chmod 755 "$install_path"
    printf "%s\n" "Installed: $program_name."
    verify_application "$program_name"
  fi
}
export -f install_program

# Label: Install Node
# Description: Install and setup Node for local development.
install_node() {
  if [[ ! -x "$(command -v node)" ]]; then
    "$(get_homebrew_bin_root)/fnm" install --latest
  fi
}
export -f install_node

# Label: Install Ruby
# Description: Install and setup Ruby for local development.
install_ruby() {
  local version=""

  version="$(cat $HOME/.ruby-version | tr -d '\n')"

  if [[ ! -x "$(command -v ruby)" && -n $(ruby --version | grep --quiet "$version") ]]; then
    "$(get_homebrew_bin_root)"/frum install "$version" \
                                            --with-openssl-dir="$(brew --prefix openssl)" \
                                            --enable-shared \
                                            --disable-silent-rules
    "$(get_homebrew_bin_root)"/frum local "$version"
  fi
}
export -f install_ruby

# Label: Install Rust
# Description: Install and setup Rust for local development.
install_rust() {
  if ! command -v cargo > /dev/null; then
    curl --proto "=https" --tlsv1.2 --fail --silent --show-error https://sh.rustup.rs | sh
  fi
}
export -f install_rust

# Label: Install Tar Application
# Description: Install application from tar file.
# Parameters: $1 (required): URL, $2 (required): Name, $3 (required): Decompress options.
install_tar_app() {
  local url="$1"
  local app_name="$2"
  local options="$3"
  local install_path=""
  local work_file="download.tar"

  install_path=$(get_install_path "$app_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      tar "$options" "$work_file"
    )

    install_app "$MAC_OS_WORK_PATH" "$app_name"
    printf "%s\n" "Installed: $app_name."
    verify_application "$app_name"
  fi
}
export -f install_tar_app

# Label: Install Zip Application
# Description: Install application from zip file.
# Parameters: $1 (required): URL, $2 (required): Name.
install_zip_app() {
  local url="$1"
  local app_name="$2"
  local install_path=""
  local work_file="download.zip"

  install_path=$(get_install_path "$app_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      unzip -q "$work_file"
      find . -type d -name "$app_name" -print -exec cp -pR {} . > /dev/null 2>&1 \;
    )

    install_app "$MAC_OS_WORK_PATH" "$app_name"
    printf "%s\n" "Installed: $app_name."
    verify_application "$app_name"
  fi
}
export -f install_zip_app

# Label: Install Zip Package
# Description: Install application from a package within a zip file.
# Parameters: $1 (required): URL, $2 (required): Application name.
install_zip_pkg() {
  local url="$1"
  local app_name="$2"
  local install_path=""
  local work_file="download.zip"

  install_path=$(get_install_path "$app_name")

  if [[ ! -e "$install_path" ]]; then
    download_file "$url" "$work_file"

    (
      printf "Preparing...\n"
      cd "$MAC_OS_WORK_PATH"
      unzip -q "$work_file"
    )

    install_pkg "$MAC_OS_WORK_PATH" "$app_name"
    printf "%s\n" "Installed: $app_name."
    verify_application "$app_name"
  fi
}
export -f install_zip_pkg

# Label: Mount Image
# Description: Mount disk image.
# Parameters: $1 (required): Path.
mount_image() {
  printf "%s\n" "Mounting image..."
  hdiutil attach -quiet -nobrowse -noautoopen "$1"
}
export -f mount_image

# Label: Unmount Image
# Description: Unmount disk image.
# Parameters: $1 (required): Path.
unmount_image() {
  printf "%s\n" "Unmounting image..."
  hdiutil detach -force "$1"
}
export -f unmount_image
