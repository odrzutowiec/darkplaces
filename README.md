# Horsepower/Darkplaces Engine

## Setup
Below are platform-specific steps to grab dependencies and set up the build environment. See below for the actual compile instructions.

### Windows (MSYS2):

1. Install MSYS2, found [here](https://www.msys2.org/).
2. Once you've installed MSYS2 and have fully updated it, open an MSYS2 terminal and input the following command:

```
pacman -S --needed gcc make cmake mingw-w64-x86_64-{toolchain,libjpeg-turbo,libpng,libogg,libvorbis,sdl2}
```

### Windows (Visual Studio):

While possible, the build script requires Bash anyway, which can be found in
Git. No instructions are available yet and you'll have to grab the dependencies
yourself. Assuming you've done all of this, skip to "Compile".

### Debian/Ubuntu:

1. Install the packages by entering the following command in a terminal as root:

```
apt install build-essential cmake lib{sdl2,jpeg,png,vorbis,ogg}-dev
```

### MacOS:

1. Install Xcode and CMake.
2. Open a terminal and enter this command (as root) to install Xcode's and
CMake's command-line tools:

```
xcode-select --install && sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install
```
3. Install Homebrew by entering the following command.

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
4. Install the packages by entering the following command as root:

```
brew install sdl2 libjpeg libpng libvorbis
```

### FreeBSD:

1. Install the packages by entering the following command in a terminal as root:
```
pkg install cmake SDL2 jpeg png vorbis
```

### OpenIndiana:

1. Install the packages by entering the following command in a terminal as root:

```
pkg install build-essential gcc-8 SDL2 libjpeg libpng libvorbis
```

### Android:

Coming soon.

## Compile

### Using build.sh:
1. Change directory to the root of the repository if you haven't already.
2. Run ./build.sh and follow the instructions.

See ./build.sh --help for documentation of the script.

### Using CMake directly:
1. cd into the "engine" subdirectory and run the following command:
```
cmake -B<location to copy build files> .
```
**NOTE**: *In-source builds are not forbidden but are discouraged and may not work properly, especially with Eclipse. Make sure you specify a directory outside of the engine subdirectory, and either outside of, or in a subdirectory of the repository root.*

If you wish to specify a name for your project, you may prepend the environment variable "HPOPTION_PROJECT=name". Otherwise, it will assume the default of "horsepower".

To point CMake to an existing project, you may also prepend "HPOPTION_PROJECT_DIR=directory"

Optionally, you may use a GUI or TUI frontend such as cmake-gui or ccmake respectively, or your IDE of choice using CMake's server mode.

If you wish to change the compiler, you may prepend the CC and CXX environment variables to the command-line, or add them to the build configuration of your IDE.

Below is an example of a full command-line string instructing CMake to use a project called "testing" located in "game/testing" with the build directory set to "output/testing", and using clang and clang++.

```
HPOPTION_PROJECT="testing" HPOPTION_PROJECT_DIR="../game/testing" CC="clang" CXX="clang++" cmake -B../output/testing .
```
### Additional notes:

You may use the generated build file directly (whether make, ninja, or otherwise) for subsequent builds.

If you use CMake directly, your build configuration will still be cached in case you decide to use the build script later.

Note: Due to a deficiency in CMake, the build threads and extra CMake options are not saved properly.