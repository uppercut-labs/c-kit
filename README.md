# c-kit

Small, focused C libraries from Uppercut Labs. Each package is a folder that builds on its own with CMake and is taken into a project at a release tag. C libraries have no package index, so there is nothing to publish: a release is a git tag.

There are no packages here right now. The first one, `port-input-harness`, moved to [game-kit](https://github.com/uppercut-labs/game-kit) on 2026-11-24 with the other game development packages, so this repo stays for general-purpose C.

Its `port-input-harness@0.1.0` tag stays in this repository, so a project already pinned to it keeps building. New versions are tagged in game-kit:

```cmake
include(FetchContent)
FetchContent_Declare(port_input_harness
  GIT_REPOSITORY https://github.com/uppercut-labs/game-kit.git
  GIT_TAG        port-input-harness@<version>
  GIT_SHALLOW    TRUE
  SOURCE_SUBDIR  packages/port-input-harness)
FetchContent_MakeAvailable(port_input_harness)
```

## Using a package

Fetch it at a tag with CMake `FetchContent`, or vendor the folder and `add_subdirectory` it. Each package README has the exact lines and an example project.

## Working in this repo

You need CMake 3.20 or later, Ninja, a C11 compiler, Python 3.8 or later and whatever a package lists. The full check builds every package, runs its tests, and builds each package's example consumer:

| System | Command | Shell |
| --- | --- | --- |
| Windows | `.\tools\check.ps1` | PowerShell 5.1 or 7 (with MSYS2 UCRT64 on `PATH`: `C:\msys64\ucrt64\bin`, packages `mingw-w64-ucrt-x86_64-{clang,cmake,ninja}`) |
| macOS | `./tools/check.sh` | Bash or zsh (`brew install cmake ninja`) |
| Linux | `./tools/check.sh` | Bash (`apt install cmake ninja-build gcc python3`) |

Each package lives in `packages/<name>` with its own `CMakeLists.txt`, README, licence, tests, examples and docs. Packages have no dependencies on each other unless their README says so. A package's tests must run without a display, a GPU or hardware, so they run in a plain container.

`tools/release_gate.py` is the one release tool: a Python 3 script that scans the source, the history and the packed source tarball before a release. It runs the same on every system.

See [RELEASING.md](RELEASING.md) for how a version is released.

## Licence

MIT
