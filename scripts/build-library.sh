#!/bin/bash

set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BUILD_DIR=${SCRIPT_DIR}/../build
echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "BUILD_DIR=$BUILD_DIR"
cd ${SCRIPT_DIR}

PROFILE=$1
OUTPUT_LIB_DIR=../lib/$PROFILE
PROFILE_PARAMS="--profile ../profiles/$PROFILE.profile"

if [[ -n "$2" ]]; then
  OUTPUT_LIB_DIR=../lib/$2
fi

if [[ "$PROFILE" == *"android"* ]]; then
  PROFILE_PARAMS="--profile:host ../profiles/$PROFILE.profile --profile:build default"
fi

mkdir -p ${OUTPUT_LIB_DIR}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
conan install .. $PROFILE_PARAMS --build=missing
cd ${SCRIPT_DIR}

# Find the .pc file (libuv or libuv-static)
PC_FILE=$(find ${BUILD_DIR} -name "libuv*.pc" | head -n1)

echo "PC_FILE=$PC_FILE"

prefix=$(sed -n 's|^prefix=\(.*\)|\1|p' "$PC_FILE")
libdir=$(sed -n "s|^libdir=\${prefix}/\(.*\)|$prefix/\1|p" "$PC_FILE")
includedir=$(sed -n "s|^includedir=\${prefix}/\(.*\)|$prefix/\1|p" "$PC_FILE")

echo "prefix=$prefix"
echo "libdir=$libdir"
echo "includedir=$includedir"



if [[ -d "$includedir" && ! -d ../include ]]; then
  echo "Copying includes from $includedir"
  cp -r "$includedir" ../include
fi

if [[ -d "$libdir" ]]; then
  echo "Copying libs from $libdir to $OUTPUT_LIB_DIR"
  cp -r "$libdir"/* "$OUTPUT_LIB_DIR"
else
  echo "Library directory not found in $libdir"
  exit 1
fi

# Clean up
rm -rf ${BUILD_DIR}