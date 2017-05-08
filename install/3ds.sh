#!/bin/bash


VERSION_CTRULIB="1.2.1"
VERSION_CITRO3D="1.2.0"
VERSION_ZLIB="1.2.8"

DIR_INSTALL="$HOME/devkitPro"

DEVKITARM_DOWNLOAD="https://sourceforge.net/projects/devkitpro/files/devkitARM/devkitARM_r46/devkitARM_r46-x86_64-linux.tar.bz2/download"
LIBCTRU_DOWNLOAD="https://sourceforge.net/projects/devkitpro/files/libctru/1.2.1/libctru-1.2.1.tar.bz2/download"
LIBCITRO3D_DOWNLOAD="https://sourceforge.net/projects/devkitpro/files/citro3d/1.2.0/citro3d-1.2.0.tar.bz2/download"
TOOLS_3DS_DOWNLOAD="https://github.com/cpp3ds/3ds-tools/releases/download/r6/3ds-tools-linux-r6.tar.gz"
SHELL_PROFILE=~/.profile

SHELL_PROFILE_CHANGED=0
SETUP_MANUAL_ENVIRONMENT_DEVKITARM=0
SETUP_MANUAL_ENVIRONMENT_CPP3DS=0
AUTO_CHANGE_SHELL_PROFILE=0

CPP3DS_PORTLIBS=("libz.a" "libogg.a" "libpng.a" "libfreetype.a" "libjpeg.a" "libfmt.a" "libfaad.a" "libvorbisidec.a")
CPP3DS_PORTLIBS_TARGET=("zlib" "libogg" "libpng" "freetype" "libjpeg-turbo" "fmt" "faad2" "tremor")
CPP3DS_PORTLIBS_MUST_COMPILE=(0 0 0 0 0 0 0)
CPP3DS_PORTLIBS_HAVE_TO_COMPILE=0

PORTLIBS_COMMANDS_REQUIREMENT=("make" "cmake" "autoreconf" "autoconf" "automake" "libtoolize" "pkg-config" "git")
PORTLIBS_APT_PKG_COMMANDS=("build-essential", "cmake", "autoconf", "autoconf", "autoconf", "libtool", "pkg-config", "git")
PORTLIBS_GIT="https://github.com/Naxann/3ds_portlibs"

BUILD_COMMANDS_REQUIREMENT=("make" "cmake" "autoreconf" "autoconf" "automake" "libtoolize" "pkg-config")

TOOLS_3DS_EXECUTABLES=("3dsxtool" "bannertool" "makerom" "nihstro-assemble" "nihstro-disassemble")

commandExists() {
	return $(command -v $1 >/dev/null 2>&1);
}

hasEnvironmentShellProfile() {
	return $(test -f ~/.profile;echo $?)
}

libctru_libpath() {
	echo $DEVKITPRO/libctru/lib/libctru.a
}
citro3d_libpath() {
	echo $DEVKITPRO/libctru/lib/libcitro3d.a
}
libExistsWithVersion() {
	export PKG_CONFIG_PATH=arm-none-eabi-pkg-config
	VERSION=$(pkg-config --modversion $1 2>/dev/null)
	if [ "$2" = "$VERSION" ]; then
		return 0;
	else
		return 1;
	fi
}

hasRequirements3dsTools() {
	HAS_REQUIREMENTS=0
	for commandName in ${PORTLIBS_COMMANDS_REQUIREMENT[@]}
	do
		if ! commandExists $commandName; then
			HAS_REQUIREMENTS=1
			break
		fi
	done
	return $HAS_REQUIREMENTS;
}

hasRequirementsBuild() {
	HAS_REQUIREMENTS=0
	for commandName in ${BUILD_COMMANDS_REQUIREMENT[@]}
	do
		if ! commandExists $commandName; then
			HAS_REQUIREMENTS=1
			break
		fi
	done
	return $HAS_REQUIREMENTS;
}

hasRequirementsFullInstall() {
	return hasRequirements3dsTools
}

functionExistsInLib() {
	NM=$DEVKITARM/bin/arm-none-eabi-nm
	$($NM $1 | grep " T $2\$" >/dev/null 2>&1)
	return $?
}

isLibCtru_121() {
	functionExistsInLib $(libctru_libpath) NIMS_StartDownload && functionExistsInLib $(libctru_libpath) GPUCMD_Finalize
}

hasDevKitPRO() {
	return $(test -d "$DEVKITPRO";echo $?)
}

hasDevKitARM() {
	return $(test -d "$DEVKITARM";echo $?)
}

hasLibCtru() {
	return $(test -f $(libctru_libpath);echo $?)
}

hasLibCitro3D() {
	return $(test -f $(citro3d_libpath);echo $?)
}

download() {
	wget -q --show-progress --no-check-certificate -O "$1" "$2"
}

installLibCtru() {
	checkWGetAndExit
	PATH_DOWNLOAD=$(mktemp)
	DIR_LIBCTRU=$DEVKITPRO/libctru
	printf "Downloading libctru $VERSION_CTRULIB...\n"
	download $PATH_DOWNLOAD $LIBCTRU_DOWNLOAD
	if [ ! $? -eq 0 ]; then
		printf "Couldn't download libctru. Exiting installation...\n"
		exit
	fi
	mkdir -p $DIR_LIBCTRU
	printf "Uncompressing libctru in $DIR_LIBCTRU..."
	tar -xaf $PATH_DOWNLOAD -C "$DIR_LIBCTRU"
	rm -rf $PATH_DOWNLOAD
	printf "done!\n"

}

installLibCitro3D() {
	checkWGetAndExit
	PATH_DOWNLOAD=$(mktemp)
	DIR_LIBCTRU=$DEVKITPRO/libctru
	printf "Downloading citro3D $VERSION_CITRO3D...\n"
	download $PATH_DOWNLOAD $LIBCITRO3D_DOWNLOAD
	if [ ! $? -eq 0 ]; then
		printf "Couldn't download citro3D. Exiting installation...\n"
		exit
	fi
	mkdir -p $DIR_LIBCTRU
	printf "Uncompressing citro3D in $DIR_LIBCTRU..."
	tar -xaf $PATH_DOWNLOAD -C "$DIR_LIBCTRU"
	rm -rf $PATH_DOWNLOAD
	printf "done!\n"
}

installDevKitARM() {
	checkWGetAndExit
	PATH_DOWNLOAD=$(mktemp)
	printf "Downloading devkitARM...\n"
	download $PATH_DOWNLOAD $DEVKITARM_DOWNLOAD
	if [ ! $? -eq 0 ]; then
		printf "Couldn't download devkitARM. Exiting installation...\n"
		exit
	fi
	mkdir -p "$DIR_INSTALL"
	printf "Uncompressing devkitARM in $DIR_INSTALL..."
	tar -xaf $PATH_DOWNLOAD -C "$DIR_INSTALL"
	printf "done !\n"

	SETUP_MANUAL_ENVIRONMENT_DEVKITARM=1

	if hasEnvironmentShellProfile && [ $AUTO_CHANGE_SHELL_PROFILE -eq 1 ]; then
		printf "\n## Environment variable for developing 3DS Homebrew\n" >> $SHELL_PROFILE
		printf "export DEVKITPRO=$DIR_INSTALL\n" >> $SHELL_PROFILE
		printf "export DEVKITARM=\$DEVKITPRO/devkitARM\n" >> $SHELL_PROFILE
		SETUP_MANUAL_ENVIRONMENT_DEVKITARM=0
		SHELL_PROFILE_CHANGED=1
	fi

	export DEVKITPRO=$DIR_INSTALL
	export DEVKITARM=$DEVKITPRO/devkitARM
	rm -rf $PATH_DOWNLOAD

}

checkWGetAndExit() {
	if ! commandExists "wget"; then
		printf "Please install the package containing wget command and retry the installation\n"
		exit
	fi
}

lackEnvironmentVariable() {
	if [ "$CPP3DS" == "" ] || [ "$DEVKITARM" == "" ] || [ "$DEVKITPRO" == "" ]; then
		return 0
	else
		return 1
	fi
}

lack3dsTools() {
	HAS_ALL_TOOLS=1
	for executableName in ${TOOLS_3DS_EXECUTABLES[@]}
	do
		if [ ! -f "$DEVKITARM/bin/$executableName" ]; then
			HAS_ALL_TOOLS=0
			break
		fi
	done
	return $HAS_ALL_TOOLS;
}

###############################
# Installation of devkitARM
# wget-only
###############################

if lackEnvironmentVariable && hasEnvironmentShellProfile; then
while true; do
	read -p "Do you want the script to add environment variable directly in your $SHELL_PROFILE? " yn
		case $yn in
			[Yy]* ) AUTO_CHANGE_SHELL_PROFILE=1; break;;
			[Nn]* ) break;;
			* ) printf "Please answer yes or no.\n";;
		esac
done
fi

printf "Checking devkitPRO..."
if hasDevKitPRO; then
	printf "installed.\n"
	DIR_INSTALL=$DEVKITPRO
else
	printf "not installed.\n"
fi

printf "Checking devkitARM..."
if hasDevKitARM; then
	printf "installed.\n"
else
	printf "not installed.\n"
	while true; do
		read -p "devkitARM is likely not installed, or path is broken. Do you wish to install it ? " yn
		case $yn in
			[Yy]* ) installDevKitARM; break;;
			[Nn]* ) break;;
			* ) echo "Please answer yes or no.";;
		esac
	done
fi

########################################
# Installation of ctrulib and citro3d
# wget-only
########################################

printf "Checking ctrulib..."
if hasLibCtru; then
	printf "installed.\n"
	printf "Checking ctrulib version ..."
	if ! isLibCtru_121; then
		printf "error\nThe current libctru installed is not the version $VERSION_CTRULIB\n"
		printf "citro3d $VERSION_CITRO3D and cpp3ds work only with libctru-$VERSION_CTRULIB\n"
		printf "Remove libctru directory in $DEVKITPRO or install the $VERSION_CTRULIB by yourself.\n"
		exit
	fi
	printf "$VERSION_CTRULIB ok\n"
else
	printf "not installed.\n"
	if ! commandExists "wget"; then
		printf "Please install the package containing wget command and retry the installation\n"
		exit
	fi
	installLibCtru
fi

printf "Checking citro3d..."

if hasLibCitro3D; then
	printf "installed.\n"
else
	printf "not installed.\n"
	if ! commandExists "wget"; then
		printf "Please install the package containing wget command and retry the installation\n"
		exit
	fi
	installLibCitro3D
fi

########################################
# Copying / compiling portlibs
########################################

# First we copy portlibs. portlibs are present on a cpp3ds release to avoid compiling
printf "Checking presence of portlibs in parent directory..."
if [ -d "../portlibs" ]; then
	printf "yes\nCopying portlibs in \$DEVKITPRO/portlibs/armv6k/..."
	cp -r "../portlibs/*" "$DEVKITPRO/portlibs/armv6k"
	printf "yes\n"
else
	printf "no\n"
fi

# Then we check if we have the libs
i=0
for filenameLib in ${CPP3DS_PORTLIBS[@]}
do
    printf "Checking portlibs ${CPP3DS_PORTLIBS_TARGET[i]}..."
	if [ -f "$DEVKITPRO/portlibs/armv6k/lib/$filenameLib" ]; then
		printf "yes\n"
	else
		printf "no\n"
		CPP3DS_PORTLIBS_MUST_COMPILE[i]=1
		CPP3DS_PORTLIBS_HAVE_TO_COMPILE=1
	fi
	((i++))
done

if [ $CPP3DS_PORTLIBS_HAVE_TO_COMPILE -eq 1 ]; then
	printf "Some portlibs are not present and need to be compiled\n"
	if hasRequirements3dsTools; then
		printf "Cloning 3ds_portlibs git...\n"
		TEMP_DIR=$(mktemp -d)
		git clone $PORTLIBS_GIT $TEMP_DIR
		printf "Compiling portlibs missing...\n"
		i=0
		for targetLib in ${CPP3DS_PORTLIBS_TARGET[@]}
		do
			if [ ${CPP3DS_PORTLIBS_MUST_COMPILE[i]} -eq 0 ]; then
				((i++))
				continue
			fi
			printf "Cross-compiling $targetLib for 3DS..."
			make -C $TEMP_DIR $targetLib >> $TEMP_DIR/compile.log 2>> $TEMP_DIR/compile.log
			if [ ! $? -eq 0 ]; then
				printf "error\nAborting installation. Please check $TEMP_DIR/compile.log for more information."
				exit
			fi
			printf "ok\n"
			if [ "$targetLib" == "zlib" ]; then
				printf "Installing $targetLib in \$DEVKITPRO/portlibs..."
				make -C $TEMP_DIR install-zlib >> $TEMP_DIR/compile.log 2>> $TEMP_DIR/compile.log
			elif [ "$targetLib" == "libogg" ] || [ "$targetLib" == "libpng" ]; then
				printf "Installing $targetLib in \$DEVKITPRO/portlibs..."
				make -C $TEMP_DIR install >> $TEMP_DIR/compile.log 2>> $TEMP_DIR/compile.log
			fi
			if [ "$targetLib" == "zlib" ] || [ "$targetLib" == "libogg" ] || [ "$targetLib" == "libpng" ]; then
				if [ ! $? -eq 0 ]; then
					printf "error\nAborting installation. Please check $TEMP_DIR/compile.log for more information."
					exit
				fi
				printf "ok\n"
			fi
			((i++))

		done
		printf "Installing libs in \$DEVKITPRO/portlibs..."
		make -C $TEMP_DIR install >> $TEMP_DIR/compile.log 2>> $TEMP_DIR/compile.log
		if [ $? -eq 1 ]; then
			printf "Installation of portlibs failed.\nAborting installation. Please check $TEMP_DIR/compile.log for more information."
			exit
		fi
		printf "ok\n"
		rm -rf $TEMP_DIR

	else
		printf "You have not the requirements for building the porlibs. You need these commands :\n"
		printf "     "
		for commandName in ${PORTLIBS_COMMANDS_REQUIREMENT[@]}
		do
			if ! commandExists $commandName; then
				printf " $commandName"
			fi
		done
		printf "\n"
		printf "Please install the package corresponding to those commands or install manually the portlibs required.\n"
		exit
	fi
fi

########################################
# Getting last 3dstools already compiled
########################################

printf "Checking if complementary 3ds tools are installed..."

if lack3dsTools; then
	printf "no\n"
	printf "Download last executables of 3dstools for Linux...\n"
	checkWGetAndExit
	PATH_DOWNLOAD=$(mktemp)
	download $PATH_DOWNLOAD $TOOLS_3DS_DOWNLOAD
	if [ ! $? -eq 0 ]; then
		printf "Couldn't download 3dstools. Exiting installation...\n"
		exit
	fi
	printf "Uncompressing 3dstools in \$DEVKITARM/bin..."
	tar -xaf $PATH_DOWNLOAD -C "$DEVKITARM/bin" --strip 1
	printf "ok\n"
	rm $PATH_DOWNLOAD
else
	printf "yes\n"
fi
########################################
# Copying / compiling cpp3ds
########################################

printf "Checking if CPP3DS environment var is set..."
if [ "$CPP3DS" == "" ]; then
	printf "no\n"
	export CPP3DS=$DEVKITPRO/cpp3ds
	mkdir -p $CPP3DS

	SETUP_MANUAL_ENVIRONMENT_CPP3DS=1
	if hasEnvironmentShellProfile && [ $AUTO_CHANGE_SHELL_PROFILE -eq 1 ]; then
		printf "\n## Environment variable for developing 3DS Homebrew with cpp3ds\n" >> $SHELL_PROFILE
		printf "export CPP3DS=\$DEVKITPRO/cpp3ds\n" >> $SHELL_PROFILE
		SETUP_MANUAL_ENVIRONMENT_CPP3DS=0
		SHELL_PROFILE_CHANGED=1
		printf "Environment variable \$CPP3DS added to your $SHELL_PROFILE.\n"
	fi
else
	printf "yes\n"
fi

mkdir -p $CPP3DS
mkdir -p $CPP3DS/lib
mkdir -p $CPP3DS/include
mkdir -p $CPP3DS/cmake

printf "Checking type of installation..."
if [ ! -d "../src/" ]; then
	printf "release\n"
	printf "yes\nCopying cpp3ds in \$DEVKITPRO/portlibs/armv6k/..."
	cp -r "../lib/*" "$CPP3DS/"
	cp -r "../include" "$CPP3DS/"
	cp -r "../cmake" "$CPP3DS/"
	printf "ok\n"
else
	printf "from source\n"
	if ! hasRequirementsBuild; then
		printf "You have not the requirements for building the lib. You need these commands :\n"
		printf "     "
		for commandName in ${BUILD_COMMANDS_REQUIREMENT[@]}
		do
			if ! commandExists $commandName; then
				printf " $commandName"
			fi
		done
		printf "\n"
		printf "Please install the package corresponding to those commands and retry the installation from source.\n"
		exit
	fi
	DIR_SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	TEMP_DIR=$(mktemp -d)
	printf "Compiling cpp3ds from source...\n"
	cd $TEMP_DIR
	cmake -DBUILD_EMULATOR=OFF -DENABLE_OGG=ON -DENABLE_AAC=ON -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF "$DIR_SOURCE/../"
	make
	printf "Installing cpp3ds into directory $CPP3DS..."
	mv lib/* $CPP3DS/lib
	printf "ok"
	cd $DIR_SOURCE
	rm -rf $TEMP_DIR
	cp -r "../include" "$CPP3DS/"
	cp -r "../cmake" "$CPP3DS/"
fi



printf "\n"
if [ $SHELL_PROFILE_CHANGED -eq 1 ]; then
	printf "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
	printf "Your $SHELL_PROFILE was modified. Please refresh your shell with the following command for environment var to be set : \n"
	printf "source $SHELL_PROFILE\n"
	printf "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
fi

if [ $SETUP_MANUAL_ENVIRONMENT_DEVKITARM -eq 1 ] || [ $SETUP_MANUAL_ENVIRONMENT_CPP3DS -eq 1 ]; then
	printf "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
	printf "Set the following environment variables to these values : \n"
	if [ $SETUP_MANUAL_ENVIRONMENT_DEVKITARM -eq 1 ]; then
		printf "DEVKITPRO=$DEVKITPRO\n"
		printf "DEVKITARM=$DEVKITPRO/devkitARM\n"
	fi
	if [ $SETUP_MANUAL_ENVIRONMENT_CPP3DS -eq 1 ]; then
		printf "CPP3DS=$DEVKITPRO/cpp3ds\n"
	fi
	printf "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n"
fi

printf "Installation of CPP3DS done !\n"
