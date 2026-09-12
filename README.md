# cpp-release-lab

A deliberately small C++20 Hello World application for exercising a native,
multi-platform release pipeline.

## Architecture

The repository builds one executable, `cpp-release-lab`, directly from
`src/main.cpp`. The application uses `fmt` from the vcpkg manifest and has no
library layer or test framework. CMake reads the release number from `VERSION`
and generates the version header used by `--version`. CTest drives the built
CLI to cover the greeting, help, version, and invalid-argument behavior. The
clang-format profile follows the public QVAC C++ lint package.

## Prerequisites

- CMake 3.25 or newer
- Ninja
- A C++20 compiler
- Git
- vcpkg at commit `16c71a39e5a0fc0bdb3fad03beef8f38ee00ee3b`

Set `VCPKG_ROOT` to the vcpkg checkout. A fresh Unix checkout can be prepared
with:

```sh
git clone https://github.com/microsoft/vcpkg.git "$VCPKG_ROOT"
git -C "$VCPKG_ROOT" checkout --detach 16c71a39e5a0fc0bdb3fad03beef8f38ee00ee3b
"$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics
```

On Windows, run `bootstrap-vcpkg.bat -disableMetrics` instead of the final
command.

## Local development

```sh
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

The CLI supports these operations:

```sh
./build/dev/cpp-release-lab
./build/dev/cpp-release-lab --version
./build/dev/cpp-release-lab --help
```

Use `build/dev/cpp-release-lab.exe` on Windows.

## Reproduce a release package

The release workflow uses the same `release` preset and commands:

```sh
cmake --preset release
cmake --build --preset release
ctest --preset release
cmake --install build/release --prefix stage
cpack --config build/release/CPackConfig.cmake
./stage/bin/cpp-release-lab
```

On Windows, configure with the static vcpkg triplet before running the remaining
commands:

```powershell
cmake --preset release -DVCPKG_TARGET_TRIPLET=x64-windows-static
```

Use `stage/bin/cpp-release-lab.exe` for the final smoke run on Windows. CPack
writes a ZIP on Windows and a TGZ elsewhere under `build/release/package`. The
archive filename includes the application version, target platform, and target
architecture.

## Supported platforms

CI builds and packages on the native GitHub-hosted runners used by the release
workflow:

- Ubuntu 24.04
- macOS 14
- Windows Server 2022

## Versioning and releases

`VERSION` is the single source of truth and contains a SemVer release number.
To release, change that file, merge the change to `main`, and push a tag whose
name is exactly `v` followed by the file contents, such as `v0.1.0`.

The release workflow rejects non-canonical or mismatched versions and tags, and
requires the tagged commit to be reachable from `origin/main` before building.
It then invokes the reusable three-platform package workflow, creates
`SHA256SUMS`, publishes GitHub build-provenance attestations, and creates the
GitHub Release. Re-running the workflow replaces existing assets so release
publication is idempotent.

A repository ruleset or tag protection rule for `v*` is required. Restrict tag
creation, updates, and deletion to trusted maintainers or release automation,
and create release tags only from reviewed `main` commits. Workflow checks alone
cannot defend against a tag targeting a commit that also modifies or removes
those checks.
