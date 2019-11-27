#!/bin/bash

### Horsepower/Darkplaces Build Script ###

#---------------------------------------------------------------#
# AUTHOR: David Knapp (Cloudwalk)                               #
# LICENSE: GPL2.0 or later                                      #
# Copyright (C) 2019 David Knapp                                #
#---------------------------------------------------------------#

### DESCRIPTION ###
# Stage 1 will take user input and set variables based on user input.
# Stage 2 will validate user input, check if directories exist, etc...
# Stage 3 will run the build system based on user input.

# This script will only work with bash.
# Putting this at the top so it will cleanly check for bash and exit before
# parsing the rest of the script and vomiting syntax errors.
if [ -z "${BASH_VERSION:-}" ]; then
	echo "This script requires bash."
	exit 1
fi

#------------------------------------------------------------------------------#

### HELPER FUNCTIONS ###
perror()
{
	printf -- "\e[31m$1\e[0m"
}

pwarn()
{
	printf -- "\e[33m$1\e[0m"
}

psuccess()
{
	printf -- "\e[32m$1\e[0m"
}

phelp()
{
	printf "
Usage: $me [OPTIONS] <PROJECT>

Options
    --build             compile the specified project
    --threads=          set how many threads to compile with
    --generator=        cmake generator to use. Run 'cmake --help' for a list
    --cmake-options=    pass additional options to cmake
    --config-dir=       override the location of the config.cmake file
    --build-dir=        override the location cmake will write build files
    --reset-all         delete all project build files and the cache
    --reset-build       delete all project build files only
    --reset-cache       delete the cache only
    --expert            display prompts for every single option
    --nocache			do not read from, or write to the cache
    --auto              do not display any prompts, even with --reset
    --help              print this message then exit

Unless you set --config-dir, the PROJECT you specify is assumed to be a
correspondingly named subdirectory of the 'game' directory. The build directory
is also relative to the config directory by default, unless --build-dir is set.
If the directory (assumed or specified) doesn't exist, a new project can be
created for you from a template.

The script maintains a cache of your build settings so you don't have to input
the same settings for a specified PROJECT more than once. You can simply run
the script with PROJECT, and optionally --build, and it will configure and/or
build PROJECT with the cached settings automatically.

This script will run in auto mode if ran from a non-interactive shell.
"
	
	exit "$1"
}

check_exist()
{
	local mode=$1
	local arg=$2
	local required=$3
	local quiet=$4

	# If nothing is specified, caller is probably looping and will specify.
	if ! [ "$arg" ]; then
		return
	fi

	local warn=""
	local withcmd=""
	if [ "$mode" == "cmd" ]; then
		withcmd="Please install '$arg' and add it to your PATH if this isn't done automatically.\n\n"
	fi

	if (( required )); then
		local notfound='perror "Could NOT find the required'
	else
		local notfound='pwarn "Could not find the'
	fi

	if ! (( quiet )); then
		# eval safety: anything after notfound is quoted and should be printed
		# literally. Escaped double quote at the end to finish notfound.
		local warn="${notfound} ${mode} '${arg}'. ${withcmd}\n\n\""
	fi

	case $mode in
		"file" )
			if [ ! -f "$arg" ]; then
				eval "${warn}"
				return 1
			fi ;;
		"dir" )
			if [ ! -d "$arg" ]; then
				eval "${warn}"
				return 1
			fi ;;
		"cmd" )
			if ! command -v "$arg" >/dev/null; then
				eval "${warn}"
				return 1
			fi ;;
	esac
	
	return 0
}

check_empty()
{
	local arg=$1

	if ! check_exist "dir" "${arg}" 0 0 ; then
		if command -v ls -A "${arg}" >/dev/null; then
			pwarn "The specified directory '$arg' is NOT empty.\n\n"
			return 1
		fi
	fi
	# Directory doesn't have to exist to reach this point but that's okay
	# because CMake will mkdir for us.
	return 0
}

### STAGE 1 ###
#------------------------------------------------------------------------------#

# Make sure the environment is sane before continuing.
check_env()
{
	local failed=0
	
	local reqdir=("$(pwd)/engine" "$(pwd)/game" "$(pwd)/game/default")
	local reqfile=("$(pwd)/.config.sh" "${reqdir[0]}/CMakeLists.txt" "${reqdir[2]}/config.cmake")

	if [ "$(id -u)" == 0 ]; then
		if (( ! option_asroot )); then
			perror "This script cannot be run as root. Use --jackass to override\n\n"
			failed+=1
		else
			pwarn "Running as root as you requested. Welcome to Jackass!\n\n"
		fi
	fi

	if [[ $- == *i* ]]; then
		option_auto=1
		pwarn "Shell is non-interactive. Prompts cannot be answered. --auto enabled.\n\n"
	else
		printf "Shell is interactive\n"
	fi

	for i in "${reqdir[@]}"; do
		check_exist "dir" "$i" 1 0
		failed+=$?
		printf "Found directory '$i'\n"
	done

	for i in "${reqfile[@]}"; do
		check_exist "file" "$i" 1 0
		failed+=$?
		printf "Found file '$i'\n"
	done

	# Make sure CMake actually exists...
	check_exist "cmd" "cmake" 1 0
	failed+=$?
	
	if (( failed )); then
		perror "The script failed to initialize. Please check the output for more information.\n\n"
		exit 1
	fi
	printf "Found cmake\n"
	printf "Initialized!\n\n"
}

#------------------------------------------------------------------------------#

option_cache_read()
{
	# This is disgusting. If anyone has a better idea, feel free to share.
	
	# Basically gotta redeclare EVERY option here, and then
	# check if the cache for the specified
	# project even exists, because we can't expand variables within variables
	# unless we use eval, and that's just gross.

	local ecache="cache_${option_project}"

	local -n ecache_project_dir="${ecache}_project_dir"
	local -n ecache_build_dir="${ecache}_build_dir"
	local -n ecache_build_threads="${ecache}_threads"
	local -n ecache_build_cmake_generator="${ecache}_cmake_generator"
	local -n ecache_build_cmake_options="${ecache}_cmake_options"

	if [ -s "$cache_file" ]; then
		source "$cache_file"
		# I don't know what I'm doing anymore. Good luck!

		if grep -q "${ecache}_" "${cache_file}" >/dev/null; then
			[ -n "${!ecache_project_dir}" ] && cache_project_dir="${ecache_project_dir}"
			[ -n "${!ecache_build_dir}" ] && cache_build_dir="${ecache_build_dir}"
			[ -n "${!ecache_build_threads}" ] && cache_build_threads="${ecache_build_threads}"
			[ -n "${!ecache_build_cmake_generator}" ] && cache_build_cmake_generator="${ecache_build_cmake_generator}"
			[ -n "${!ecache_build_cmake_options}" ] && cache_build_cmake_options="${ecache_build_cmake_options}"
		fi
	fi
}

option_cache_write()
{
	if (( ! cache_changed )); then
		if (( ! option_cache_off )); then
			if ! [ -s "$cache_file" ]; then
				printf "#!/bin/bash\n" > "$cache_file"
			fi

			reset_cache 0

			printf "
cache_${option_project}_project_dir=\"${option_project_dir}\"
cache_${option_project}_build_dir=\"${option_build_dir}\"
cache_${option_project}_threads=\"${option_build_threads}\"
cache_${option_project}_cmake_generator=\"${option_build_cmake_generator}\"
cache_${option_project}_cmake_options=\"${option_build_cmake_options}\"

" >> "$cache_file"

			printf "
Your build options for \"$option_project\" has been written to the cache. You
only have to run '$me --build $option_project' to build the same project again.

You may also use --auto to skip the prompts.

"
		else
			pwarn "The cache is disabled. Skipping write.\n\n"
		fi
	fi
}

option_cache_check()
{
	local option=$1
	local cache=$2
	
	if [ "$option" != "$cache" ]; then
		cache_changed=1
	fi
}

option_cache_list()
{
	return
}

#------------------------------------------------------------------------------#

### Generic prompt function
option_get_prompt()
{
	# Arguments
	local -n option=$1
	local default=$2
	local message=$3
	local required=$4
	local error=$5

	local default_text="[$default]"
	
	if ! [ "$default" ]; then
		default_text=""
	fi

	# No prompts in auto mode.
	if (( option_auto )); then
		if (( required )); then
			perror "$error\n"
			phelp 1
		else
			option="${default}"
			return
		fi
	fi
	
	printf -- "$message"
	read -rp " $default_text: " option
	option=${option:-$default}
	printf "\n"
	return
}

option_get_cmdline()
{
	# Iterate over any args.
	for (( i=0; i<${#args[@]}; i++)); do
		if [[ "${args[$i]}" == "-"* ]]; then
			case "${args[$i]}" in
				"--expert" )
					option_expert=1 ;;
				"--build" )
					option_run_build=1 ;;
				"--reset-all" )
					option_run_reset_build=1
					option_run_reset_cache=1 ;;
				"--reset-build" )
					option_run_reset_build=1 ;;
				"--reset-cache" )
					option_run_reset_cache=1 ;;
				#	"--list" )
					#option_cache_list=1 ;;
				"--auto" )
					pwarn "--auto is set. Prompts will not appear.\n\n"
					option_auto=1 ;;
				"--build-dir="* )
					option_build_dir=${args[$i]##--build-dir=} ;;
				"--config-dir="* )
					option_project_dir=${args[$i]##--config-dir=}
					printf "option config is $option_project" ;;
				"--threads="* )
					option_build_threads=${args[$i]##--threads=} ;;
				"--generator="* )
					option_build_cmake_generator=${args[$i]##--generator=} ;;
				"--cmake-options="* )
					option_build_cmake_options=${args[$i]##--cmake-options=} ;;
				"--nocache" )
					option_cache_off=1 ;;
				"--jackass" )
					option_asroot=1 ;;
				"--help" )
					phelp 0 ;;
				* )
					pwarn "Unknown option '${args[$i]}'\n\n"
					phelp 1 ;;
			esac
		# Last arg should be the build config, but not the first arg.
		else
			option_project=${args[$i]}
		fi
	done
}

#------------------------------------------------------------------------------#

option_get_check()
{
	if (( option_auto )) && (( option_expert )); then
		option_expert=0
		pwarn "Expert mode is useless in auto mode. Ignoring.\n\n"
	fi

	option_get_check_config

	if ! (( option_cache_off )); then
		option_cache_read
	else
		pwarn "The cache is disabled. Skipping read.\n\n"
	fi

	if (( option_run_reset_build )); then
		reset_build
	fi
	
	if (( option_run_reset_cache )); then
		reset_cache
	fi

	option_get_check_config_dir
	option_get_check_build_dir
	option_get_check_build_threads
	option_get_check_build_cmake_generator
	option_get_check_build_cmake_options
}

# If the user didn't give us anything, ask.
option_get_check_config()
{
	while ! [ "$option_project" ]; do
		option_get_prompt	\
			option_project	\
			"$cache_project"	\
			"Please specify a name for your project" \
			"" \
			""
		if [ "${option_project}" == "default" ]; then
			pwarn "H-hey...! Get your own project! That's the template. You can't use that!\n\n"
			option_project=""
		fi
	done
	option_cache_check "$option_project" "$cache_project"
}

option_get_check_config_dir()
{
	local status
	local new_config
	
	# Set the default
	if [ ! "$cache_project_dir" ]; then
		cache_project_dir="$(pwd)/game/$option_project"
	fi

	# Don't prompt for this unless something is wrong. Assume the default.
	if [ ! "$option_project_dir" ]; then
		if ! (( option_expert )); then
			option_project_dir="$cache_project_dir"
		fi
	fi

	while true; do
		if [ "$option_project_dir" ]; then
			if check_exist 'dir' "${option_project_dir}" 0 1 ; then
				option_cache_check "$option_project_dir" "$cache_project_dir"
				return	# We're good. Proceed.
			else
				printf "The directory of the specified project does not exist.\n\n"
				if [ -w "$(dirname "$option_project_dir")" ]; then
					option_get_prompt												\
						new_config														\
						"Y"														\
						"Would you like to create a new project from the template in:\n$option_project_dir?"						\
						""															\
						""
					if [[ "$new_config" =~ ^(Y|y)$ ]]; then
						cp -rv "$config_template" "$option_project_dir"
						continue
					fi
				else
					pwarn "The parent directory is also not writable or doesn't exist. Cannot create a new\nproject from the template here."
				fi
			fi
		else
			pwarn "No config directory has been specified.\n\n"
			if ! (( option_expert )); then
				pwarn "But --expert isn't set. Something is wrong with your configuration, or there's a bug in the script.\n\n"
			fi
		fi
	
		# Get our answer unless --auto is set.
		option_get_prompt														\
			option_project_dir													\
			"$cache_project_dir"																\
			"Specify the location of '$option_project'. If it doesn't exist, it can be created from a template."	\
			1																	\
			"You must provide a valid project directory with --auto set\n\n"
	done
}

option_get_check_build_dir()
{
	local status
	local finished=0
	local notwritable=0
	local force=0
	local ask=0
	
	if [ ! "$cache_build_dir" ]; then
		cache_build_dir="$option_project_dir/build"
	fi

	# Don't prompt for this unless something is wrong. Assume the default.
	if [ ! "$option_build_dir" ]; then
		if ! (( option_expert )); then
			option_build_dir="$cache_build_dir"
		fi
	fi

	while ! (( finished )); do
		if [ "$option_build_dir" ]; then
			# Check if it even exists first.
			if check_exist 'dir' "$option_build_dir" 0 1 ; then # Exists
				# Check if writable. Permissions change.
				if ! [ -w "$option_build_dir" ]; then
					pwarn "The directory '$option_build_dir' is NOT writable.\n\n"
					notwritable=1
					ask=1
				fi

				if ! (( notwritable )); then
					if ! check_empty "$option_build_dir" && [[ $cache_build_dir != "$option_build_dir" ]]; then
						option_get_prompt												\
							force														\
							"y/N"														\
							"Would you like to build here anyway?"						\
							1															\
							"You must specify an empty directory when --auto is set."
						if ! [[ "$force" =~ ^(Y|y)$ ]]; then
							ask=1
						fi
					fi
				fi
			else
				pwarn "Build directory doesn't exist. CMake will create the directory for you.\n\n"
			fi
		else
			ask=1
		fi
		
		# Ask if dir not empty and user not forcing, or if not writable.
		if (( ask )); then
			option_get_prompt													\
				option_build_dir												\
				"$cache_build_dir"												\
				"Please provide an empty and writable directory for the build files"			\
				1	\
				"You must provide a valid build directory with --auto set\n\n"
			ask=0
		else
			finished=1
		fi
	done
}

option_get_check_build_threads()
{
	option_get_prompt										\
		option_build_threads								\
		"$cache_build_threads"								\
		"How many threads would you like to compile with?"	\
		""	\
		""
	option_cache_check "$option_build_threads" "$cache_build_threads"
}

option_get_check_build_cmake_generator()
{
	option_get_prompt													\
		option_build_cmake_generator	\
		"$cache_build_cmake_generator"	\
		"What CMake generator would you like to use?"	\
		""	\
		""
	option_cache_check "$option_build_cmake_generator" "$cache_build_cmake_generator"
}

option_get_check_build_cmake_options()
{
	if ! (( option_expert )); then
		return
	else
		option_get_prompt	\
			option_build_cmake_options	\
			"$cache_build_cmake_options"	\
			"Specify additional command-line options for CMake"	\
			""	\
			""
	fi
	option_cache_check "$option_build_cmake_options" "$cache_build_cmake_options"
}

#------------------------------------------------------------------------------#

build_start_config()
{
	local cmd_cmake_config="cmake ./engine -G\"${option_build_cmake_generator}\" -B$option_build_dir -DPROJ_DIR=$option_project_dir $option_build_cmake_options"

	printf "Running CMake...\n\n"	
	
	printf "Using \"${option_project}\" build config.\n\n"

	# Try to configure. If that's successful and --build was specified, then 
	# try that too.

	# Get return values.
	printf "CMake config commandline: $cmd_cmake_config\n\n"
	if eval "$cmd_cmake_config"; then
		psuccess "Configure completed successfully.\n"
	# Everything is broken.
	else
		perror "Configure failed. Please check the output for more information.\n"
		exit 1
	fi
	return
}

build_start_compile()
{
	local cmd_cmake_build="cmake --build $option_build_dir -- -j $option_build_threads"
	
	printf "CMake build commandline: $cmd_cmake_build\n\n"
	if eval "$cmd_cmake_build"; then
		psuccess "Build completed successfully.\n"
	else
		perror "Build failed, but configure was successful. Please check the output for more information.\n"
		exit 1
	fi
}

build_start()
{
	build_start_config
	if (( option_run_build )); then
		build_start_compile
	fi
}

#------------------------------------------------------------------------------#

reset_build()
{
	local status
	if ! [ "$cache_build_dir" ]; then
		pwarn "--reset-build: No build directory found for '$option_project'\n\n"
	else
		if ! [ -d "$cache_build_dir" ]; then
			pwarn "--reset-build: The build directory of '$option_project' doesn't exist. Nothing to delete.\n\n"
		else
			if ! rm -rfv "$cache_build_dir" ; then
				perror "--reset-build: Failed to delete build files under '$cache_build_dir'\n\n"
			fi
		fi
	fi
}

# You couldn't pay me to rewrite this.
reset_cache()
{
	# This whole section is a clusterfuck. Complicated awk command to try to rewrite
	# the cache for a specified project if it's changed, while leaving everything else
	# alone. It works but if the top of the cache is removed and placed at the
	# bottom, it adds a space. So, figure out how to fix that?
	local whole=$1
	local cache="cache_${option_project}_"
	local cache_new=""

	if ! [ -f "$cache_file" ]; then
		pwarn "The build cache doesn't exist. Nothing to reset or delete.\n\n"
	else
		if ! (( whole )); then
			# The spaces in this awk line are extremely important or the
			# variable won't expand. Do NOT touch this unless you know what
			# you're doing. Why it works, I don't know. Ask stackoverflow.
			cache_new="$(awk "!/$cache/ "' { print $0;next }' $cache_file)"
			echo "${cache_new}"
			[ -n "$cache_new" ] && echo "${cache_new}" > $cache_file || perror "Your cache file is corrupt or there is a bug in the script. The cache, upon reset, is supposed to at least include a shebang but is completely blank.\n\n"
		else
			rm -fv "$cache_file"
			pwarn "Deleted build cache."
		fi
	fi
}

reset_all()
{
	reset_build
	reset_cache
}

#------------------------------------------------------------------------------#

### Start ###

printf "\n\e[1;34m---Horsepower Build Wizard---\e[0m\n\n"

# Put the args in a proper array so they can be read easier.
declare -g args=("$@")
declare -g me=$0

declare -g cache_file
cache_file="$(pwd)/.buildcache"

declare -g config_template
config_template="$(pwd)/game/default"

### Default options ###
# These are changed by the cache (if it exists) and compared with user input.
declare -g cache_project="horsepower"
declare -g cache_project_dir="" # Defined later
declare -g cache_build_dir="" # Defined later
declare -g cache_build_threads=1
declare -g cache_build_cmake_options=""
declare -g cache_build_cmake_generator="Unix Makefiles"

### User options ###
declare -g option_auto=0
declare -g option_expert=0
declare -g option_asroot=0

declare -g option_run_build=0
declare -g option_run_reset_build=0
declare -g option_run_reset_cache=0
declare -g option_cache_off=0

# If any of these don't match the cache, write to it.
declare -g option_project=""
declare -g option_project_dir=""
declare -g option_build_dir=""
declare -g option_build_threads=""
declare -g option_build_cmake_options=""
declare -g option_build_cmake_generator=""

### Global variables for state tracking ###
declare -g cache_changed=0 # Set to 1 if any options don't match the cache.
# declare -g cache_loaded=0

# Make sure the environment is sane first.
check_env

option_get_cmdline

option_get_check

build_start

option_cache_write

psuccess "The Horsepower Build Wizard has completed the requested operations successfully.\n\n"

exit 0
