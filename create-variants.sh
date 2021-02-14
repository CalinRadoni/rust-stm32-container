#!/bin/bash

script_name="Builder for rust-stm32-container"
script_version="1.2.1"

#versions=("buster" "slim" "alpine")
versions=("buster" "slim")

echo "$script_name, version $script_version"

imageBaseName="calinradoni/rust-stm32"
cmd_clean=0
cmd_build=0
cmd_list=0
cmd_delete=0

function Usage () {
  echo "Usage $0 [OPTION]"
  echo
  echo "Without options this script will create a Dockerfile for each version"
  echo
  echo "-c clean"
  echo "-b build the images"
  echo "-l list images"
  echo "-d remove images"
  echo
}

build_image() {
  echo

  if [[ "$#" -ne 1 ]]; then
    printf "Parameter is missing !\n"
    return 1
  fi

  filename="$1/Dockerfile"
  if [[ ! -f "$filename" ]]; then
    printf "%s not found !\n" "$filename"
    return 1
  fi

  Name="$imageBaseName:$1"
  Dir="$1"

  if command -v "buildah" > /dev/null 2>&1; then
    printf "Building %s with buildah\n" "$Name"
    buildah build-using-dockerfile --tag "$Name" "$Dir"
    status=$?
  elif command -v "docker" > /dev/null 2>&1; then
    printf "Building %s with docker\n" "$Name"
    docker build --tag "$Name" "$Dir"
    status=$?
  else
    printf "Docker or Buildah are needed to build the image !\n"
    status=2
  fi
  return $status
}

list_images() {
  if command -v "podman" > /dev/null 2>&1; then
    podman images $imageBaseName
  elif command -v "docker" > /dev/null 2>&1; then
    docker images $imageBaseName
  fi
}

delete_images() {
  if command -v "podman" > /dev/null 2>&1; then
    cmd=podman
  elif command -v "docker" > /dev/null 2>&1; then
    cmd=docker
  fi

  for version in "${versions[@]}"; do
    image_name="$imageBaseName:$version"
    $cmd rmi "$image_name"
  done
}

while getopts ":cbld" option
do
  case $option in
    c ) cmd_clean=1;;
    b ) cmd_build=1;;
    l ) cmd_list=1;;
    d ) cmd_delete=1;;
    * ) Usage; exit 1;;
  esac
done

if [[ $cmd_clean -eq 1 ]]; then
  for version in "${versions[@]}"; do
    rm -f "${version}/Dockerfile"
  done
  exit 0
fi

if [[ $cmd_build -eq 1 ]]; then
  for version in "${versions[@]}"; do
    build_image "$version"
  done
  exit 0
fi

if [[ $cmd_list -eq 1 ]]; then
  list_images
  exit 0
fi

if [[ $cmd_delete -eq 1 ]]; then
  delete_images
  exit 0
fi

for version in "${versions[@]}"; do
  mkdir -p "${version}"
  if [[ "$version" == "alpine"* ]]; then
    template="Dockerfile.alpine.template"
  else
    template="Dockerfile.debian.template"
  fi
  sed -e "s/VERSION/$version/g" \
    $template > "${version}/Dockerfile"
done

exit 0
