# openssl-mobile

This repo provides scripts to build OpenSSL via Conan, package them for the appropriate platforms and provide cmake scripts for simple integration. Currently, the scripts support the following platforms.

* iOS 11+
* Android 9.0+ (API 28)
* macOS x86 & arm64
* Linux x86 & arm64
* Windows x64

## Building From Source

Android builds use NDK r30 (Clang 21), with API 28 as the minimum for all four
ABIs. Until Conan Center publishes r30, the build exports the checksum-pinned
upstream recipe in `recipes/android-ndk` as `android-ndk/r30@blueye/stable`.

`download.sh` uses the checkout's exact release tag, or `v3.5.9-1` for an untagged
checkout. It fails without replacing existing libraries if that release is not
yet available; build from source until the matching binaries are published.

### Prerequisites (macOS)

Assuming Homebrew is already installed, run the following to install the required dependencies and toolchains:

```
brew install conan
brew install --cask docker
open /Applications/Docker.app
```

### Prerequisites (Windows)

Install Python and Conan:

```
pip install conan
conan profile detect
```

### Build

To build OpenSSL, run the following command:

```
./build.sh
```

On macOS this builds for iOS, Android, macOS and Linux. On Windows it auto-detects the platform and builds for Windows x64.

You can also specify platforms explicitly:

```
./build.sh windows
./build.sh ios android macos linux
```

The build script also supports the following arguments:

```
--package: packages the headers and binaries into a zip file.
```

## Downloading Prebuilt Binaries

Run the following to download prebuilt binaries for all listed platforms. The script will download the release associated with the current commit you have checked out, otherwise it will download the latest release available.

```
./download.sh
```
