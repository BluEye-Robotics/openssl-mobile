# openssl-mobile

Cross-platform OpenSSL build system using Conan. Produces static libraries packaged as GitHub releases for consumption by downstream projects (Surge).

## Repository Structure

- `profiles/` - Conan profiles for each platform/arch combination (e.g. `ios-armv8.profile`, `windows-x64.profile`)
- `scripts/build-library.sh` - Core build script that runs `conan install` with a profile and copies outputs
- `build.sh` - Top-level build orchestrator. Accepts platform names (`ios`, `android`, `macos`, `linux`, `windows`) and `--package` flag
- `download.sh` - Downloads prebuilt binaries from the matching GitHub release
- `linux-dockerfile` - Docker image for Linux cross-compilation (armv8 + x86)
- `conanfile.txt` - Declares OpenSSL version and Conan generators
- `.github/workflows/ci-build.yaml` - CI: builds all platforms, packages into zip, publishes GitHub release on tag push

## Build Flow

1. `build.sh` calls `scripts/build-library.sh <profile> [output-dir]` for each arch
2. `build-library.sh` runs `conan install` with the matching profile, extracts lib/include paths from generated `.pc` files, and copies artifacts
3. `build.sh` post-processes platform outputs (lipo for macOS universal, xcframework for iOS, library rename for Windows)
4. `--package` creates a `package.zip` with `include/` and `lib/`

## Supported Platforms

- iOS (armv8, simulator armv8+x86 → xcframework)
- Android (armv8, armv7, x86_64, x86)
- macOS (armv8 + x86 → universal binary via lipo)
- Linux (armv8, x86 — built in Docker)
- Windows (x64 — libraries renamed from libssl.lib/libcrypto.lib to ssl.lib/crypto.lib)

## Windows Notes

- Windows profiles use `compiler.runtime=static` for static CRT linking
- Conan auto-detects the MSVC version (no hardcoded compiler version in profiles)
- Output libraries are renamed to match CMake link expectations: `ssl.lib`, `crypto.lib`

## CI/CD

- Triggered on push to `main` and version tags (`v*`)
- Three parallel build jobs: apple-android (macOS runner), linux (Ubuntu + Docker), windows (Windows runner)
- Artifacts merged into a single `package.zip` and uploaded as a GitHub release on tag push

## Releasing

Push a version tag to trigger a release:

```
git tag v3.5.2-2
git push origin v3.5.2-2
```

## Dependencies

- OpenSSL version is declared in `conanfile.txt`
- Conan 2.x required
