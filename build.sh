#!/bin/bash

VERSION="1.44"

DIR="v$VERSION"
NAME="calinradoni/rust-stm32:$VERSION"

if command -v "buildah" > /dev/null 2>&1; then
    printf 'Building the image with buildah\n'
    buildah build-using-dockerfile --tag $NAME $DIR
    status=$?
elif command -v "docker" > /dev/null 2>&1; then
    printf 'Building the image with docker\n'
    docker build --tag $NAME $DIR
    status=$?
else
    printf 'Either Docker or Buildah are needed to build the image !\n'
    status=3
fi

exit $status
