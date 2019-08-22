#!/bin/bash

### Horsepower/Darkplaces Build Script ###

#---------------------------------------------------------------#
# AUTHOR: David Knapp (Cloudwalk)                               #
# LICENSE: GPL2.0 or later                                      #
# Copyright (C) 2019 David Knapp                                #
#---------------------------------------------------------------#

# This script will only work with bash.
# Putting this at the top so it will cleanly check for bash and exit before
# parsing the rest of the script and vomiting syntax errors.
if [ ! "$BASH_VERSION" ]; then
	echo "This script requires bash."
	exit 1
fi

# Make sure the environment is sane before continuing.
check_env() {
	# Some checks here.
	if [ "$(id -u)" == 0 ]; then
		printf "\e[31mThis script cannot be run as root.\e[0m\n\n"
		exit 1
	fi

	# Obviously we need the stuff this script is meant to work with...
	if [[ ! -d $(pwd)/engine/ || ! -d $(pwd)/game/ || ! -f $(pwd)/engine/CMakeLists.txt ]]; then
		printf "\e[31mThis script can't find anything at all. Either you need to put the build files\nback this instant, or somehow you grabbed this file from some random source that\ndidn't include the stuff that it actually needs. In either case, you should\nprobably stop what you're doing as you might hurt yourself...\e[0m\n\n"
		exit 1
	fi

	# Make sure CMake actually exists...
	if ! command -v cmake >/dev/null; then
		printf "\e[31mCMake was NOT found. Please install CMake and add it to your PATH if this isn't done automatically.\e[0m\n\n"
		exit
	fi

	# Template config file should not be missing.
	if [ ! -f ./.config.sh ]; then
		printf "\e[31m./.config.sh was NOT found. Please run 'git reset' or redownload the repository.\e[0m"
		exit
	fi

	# Create user-specific config file from template that's not tracked by git.
	if [ ! -f ./config.sh ]; then
		cp ./.config.sh ./config.sh
		printf "\e[33mThis appears to be the first time you're running this script. We've created a file 'config.sh' which will allow you to configure the generator and extra CMake options. You might want to edit it before continuing.\e[0m\n\n"
	fi
}

# Run the build system.
begin_config() {
	cmake_build_cmd="cmake --build $build_dir -- -j $BUILD_THREADS"
	cmake_cmd="cmake ./engine -G\"$CMAKE_GEN\" -B$build_dir -DBUILD_CONFIG=$build_config $CMAKE_OPTIONS"

	printf "Running CMake...\n\n"

	printf "Using '${build_config}' build config.\n\n"

	# Try to configure. If that's successful and --build was specified, then 
	# try that too.

	# Get return values.
	printf "CMake commandline: $cmake_cmd\n\n"
	if eval "$cmake_cmd"; then
		printf "\e[32mConfigure completed successfully.\e[0m\n"

		if [ "$compile" == true ]; then
			if eval "$cmake_build_cmd"; then
				printf "\e[32mBuild completed successfully.\e[0m\n"
			else
				printf "\e[33mBuild failed, but configure was successful. Please check the output for more information.\e[0m\n"
				exit 1
			fi
		fi
	# Everything is broken.
	else
		printf "\e[31mConfigure failed. Please check the output for more information.\e[0m\n"
		exit 1
	fi
	return
}

begin_reset() {
	if [ $force_reset ]; then
		reset_choice="y"
	else
		read -p "Delete all files and directories under '$build_config'? [y/N]: " reset_choice
	fi
	if [ "$reset_choice" == "y" ]; then
		printf "Cleaning...\n\n"
		rm -rfv $build_dir
		printf "Done!\n"
		if [[ $build || $config ]]; then
			begin_config
		fi
	else
		printf "Aborted\n"
	fi
}

# We want our build config.
get_build_config() {
	if [ ! $build_config ]; then
		printf "Please specify a directory containing a valid config.cmake, relative to the\n'projects' subdirectory.\n\n"
	fi

	while true; do
		if [ $build_config ]; then
			if [ ! -f ./game/${build_config}/config.cmake ]; then
				if [ ! -d ./game/${build_config}/ ]; then
					printf "\e[1;33mThe specified directory '${build_config}' does not exist.\e[0m\n\n"
				else
					printf "\e[1;33mCould not find a config.cmake under the specified directory '${build_config}'.\e[0m\n\n"
				fi

				if [ $from_cmdline ]; then
					exit 1
				fi
			else
				break # Got it.
			fi
		fi

		read -p "Enter directory name ['default']: " build_config
		build_config=${build_config:-default}
		printf "\n"
	done

	build_dir="./game/$build_config/build"

	if [ ! $reset ]; then
		begin_config
	else
		begin_reset
	fi
}

print_help() {
	printf "Usage: ./build.sh [OPTIONS] PROJECT\n\n"

	printf "Options\n"
	printf -- "--config	perform the configure step then exit\n"
	printf -- "--build		compile the specified project immediately\n"
	printf -- "--reset		delete all project build files\n"
	printf -- "--yes		do not prompt to delete if --reset flag is used\n"
	printf -- "--help		print this message\n\n"

	# This printf is formatted this way for alignment purposes.
	printf "\
PROJECT should point to a directory in ./game that contains a config.cmake\n\
file. If left blank, you will be prompted to enter one. If you provide an\n\
invalid name on the command-line, the script will exit and you will not be\n\
prompted (mainly to prevent autobuilds from getting stuck).\n\n"

	printf -- "Combining --reset with --build or --config will perform a fresh build or config.\n"
}

#==============================================================================#

printf "\n\e[1;34m---Horsepower Build Wizard---\e[0m\n\n"

check_env

# We'll need args.
if [ ! $1 ]; then
	printf "\e[33mNeed at least one argument\e[0m\n\n"
	print_help
	exit 1
fi



# Iterate over any args.
for i in $@; do
	if [[ $i == "-"* ]]; then
		case "$i" in
			"--build" )
				compile=true ;;
			"--config" )
				config=true ;;
			"--reset" )
				reset=true ;;
			"--yes" )
				force_reset=true ;;
			"--help" )
				print_help
				exit 0 ;;
			* )
				printf "\e[33mUnknown option '$i'\e[0m\n\n"
				print_help
				exit 1 ;;
		esac
		arg_provided=true
	# Last arg should be the build config, but not the first arg.
	elif [ ! $arg_provided ]; then
		printf "\e[33mNeed at least one option for '$i'\e[0m\n\n"
		print_help
		exit 1
	else
		build_config="$i"
	fi
done

# Compile implies config.
if [ $compile ]; then
	config=true
fi

# If build_config is defined by this point, it came from the cmdline and later
# code needs to know the difference.
if [ "$build_config" ]; then
	from_cmdline=true
fi

# Bring the config on board.
source ./config.sh

# Make sure we got the right generator for the platform.
case $(uname -s) in
	Linux|FreeBSD|OpenBSD|SunOS )
		CMAKE_GEN=$UNIX_GEN ;;
	Darwin )
		CMAKE_GEN=$MAC_GEN ;;
	# Anything else should be Windows MSYS or Cygwin.
	*)
		CMAKE_GEN=$WIN_GEN ;;
esac

get_build_config
