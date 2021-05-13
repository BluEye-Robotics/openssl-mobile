#!/bin/bash

buildLibuv() {
  PROFILE=$1
  OUTPUT_LIB_DIR=lib/$PROFILE
  OPTIONAL_ANDROID_PARAMETER=""

  if [ -n "$2" ]; then
    OUTPUT_LIB_DIR=lib/$2
  fi

  if [ $PROFILE == *"android"* ]; then
    OPTIONAL_ANDROID_PARAMETER="--build=android_ndk_installer"
  fi

  mkdir -p "$OUTPUT_LIB_DIR"
  mkdir -p "build"

  cd build
  conan install .. --profile ../profiles/$PROFILE.profile --build=libuv $OPTIONAL_ANDROID_PARAMETER
  cd ..

  if [ ! -d "include" ]; then
    INCLUDE_DIR=`grep -m1 'data/libuv/.*/include' build/conanbuildinfo.txt`
    cp -r $INCLUDE_DIR "include"
  fi

  BUILT_LIB_DIR=`grep -m1 'data/libuv/.*/lib' build/conanbuildinfo.txt`
  cp -r $BUILT_LIB_DIR/* "$OUTPUT_LIB_DIR"
}

buildiOS() {
  buildLibuv ios-armv8
  buildLibuv iossimulator-armv8
  buildLibuv iossimulator-x86

  mkdir lib/iossimulator
  lipo \
   	lib/iossimulator-armv8/libuv_a.a \
   	lib/iossimulator-x86/libuv_a.a \
   	-create -output lib/iossimulator/libuv_a.a \

  xcodebuild -create-xcframework \
    -library lib/ios-armv8/libuv_a.a \
    -library lib/iossimulator/libuv_a.a \
  	-output lib/ios/libuv.xcframework

  rm -r lib/ios-armv8 lib/iossimulator-armv8 lib/iossimulator-x86 lib/iossimulator
}

buildAndroid() {
  buildLibuv android-armv8 android/arm64_v8a
  buildLibuv android-armv7 android/armeabi
  buildLibuv android-x86 android/x86_64
}

buildMacOS() {
  buildLibuv macos-armv8 macos/armv8
  buildLibuv macos-x86 macos/x86
}

buildLinux() {
  buildLibuv linux-armv8 linux/armv8
  buildLibuv linux-x86 linux/x86
}

set -e

cd "$(dirname "$0")"

rm -r lib include

buildiOS
buildAndroid
buildMacOS
buildLinux

if [ $1 == "--package" ]; then
  zip -r package.zip include lib
  echo "Package has been created at $(pwd)/package.zip"
fi
