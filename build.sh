#!/bin/bash

buildiOS() {
  scripts/build-library.sh ios-armv8
  scripts/build-library.sh iossimulator-armv8
  scripts/build-library.sh iossimulator-x86

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
  scripts/build-library.sh android-armv8 android/arm64_v8a
  scripts/build-library.sh android-armv7 android/armeabi
  scripts/build-library.sh android-x86 android/x86_64
}

buildMacOS() {
  scripts/build-library.sh macos-armv8 macos/armv8
  scripts/build-library.sh macos-x86 macos/x86
}

buildLinux() {
  scripts/build-library.sh linux-armv8 linux/armv8
  scripts/build-library.sh linux-x86 linux/x86
}

set -e

cd "$(dirname "$0")"

rm -rf lib include

buildiOS
buildAndroid
buildMacOS
buildLinux

if [[ $1 == "--package" ]]; then
  zip -r package.zip include lib
  echo "Package has been created at $(pwd)/package.zip"
fi
