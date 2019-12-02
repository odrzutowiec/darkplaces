# Horsepower/Darkplaces Engine

Below are platform-specific steps to grab dependencies and set up the build
environment. See below for the actual compile instructions.

## Windows (MSYS2):

1. Install MSYS2, found [here](https://www.msys2.org/).
2. Once you've installed MSYS2 and have fully updated it, open an MSYS2
terminal and input the following command:

```
pacman -S --needed gcc make cmake mingw-w64-x86_64-{toolchain,libjpeg-turbo,libpng,libogg,libvorbis,sdl2}
```

## Windows (Visual Studio):

While possible, the build script requires Bash anyway, which can be found in
Git. No instructions are available yet and you'll have to grab the dependencies
yourself. Assuming you've done all of this, skip to "Compile".

## Debian/Ubuntu:

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

### Compile

1. Change directory to the root of the repository if you haven't already.
2. Run ./build.sh and follow the instructions.

See ./build.sh --help for documentation of the script.

You may use the generated build file (whether make, ninja, or otherwise) for
subsequent builds.
