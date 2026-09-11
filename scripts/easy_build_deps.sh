#!/bin/bash

# Note: this is intended to be sourced from an easy_build script, which already
# has $script_dir defined. It installs needed dependencies and then sets
# $real_os to the OS we are running on.

set -e

# Helper functions for different types of output
# Status messages should always be shown (major process titles)
status() {
    echo "$@"
}

# Verbose messages are suppressed in quiet mode
verbose() {
    if [ $QUIET_MODE -eq 0 ]; then
        echo "$@"
    fi
}

verbose "Pedigree Easy Build script"
verbose "This script will ask a couple questions and then automatically install"
verbose "dependencies and compile Pedigree for you."
verbose ""

compiler_build_options=""

if [ -d "$script_dir/build-host/src/buildutil/ext2img" ]; then
    rm -rf "$script_dir/build-host/src/buildutil/ext2img"
fi

real_os=""
nosudo=0
if [ ! -e $script_dir/.easy_os ]; then

    echo "Checking for dependencies... Which operating system are you running on?"
    echo "Cygwin, Debian/Ubuntu, OpenSuSE, Fedora, OSX, Arch, Gentoo, or some other system?"

    confirm=""
    if [ $# == 0 ]; then
        read os
    else
        os=$1
        if [ "$os" = "nosudo" ]; then
            os=$2
            nosudo=1
        elif [ "$os" = "noconfirm" ]; then
            os=$2
            confirm="-y"
        fi
    fi

    shopt -s nocasematch

    real_os=$os

    case $real_os in
        debian)
            # TODO: Not sure if the package list is any different for debian vs ubuntu?
            verbose "Installing packages with apt-get, please wait..."
            [ $nosudo = 0 ] && sudo apt-get install $confirm libmpfr-dev \
                libmpc-dev gmp3-dev sqlite3 texinfo scons genisoimage \
                u-boot-tools nasm python3-requests || echo "Warning: Some packages failed to install."
            ;;
        ubuntu)
            verbose "Installing packages with apt-get, please wait..."
            [ $nosudo = 0 ] && sudo apt-get install $confirm libmpfr-dev \
                libmpc-dev libgmp3-dev sqlite3 texinfo scons genisoimage \
                e2fsprogs u-boot-tools nasm python3-requests autoconf cmake \
                bison flex lcov || echo "Warning: Some packages failed to install."
            ;;
        opensuse)
            verbose "Installing packages with zypper, please wait..."
            set +e
            sudo zypper install mpfr-devel mpc-devel gmp3-devel sqlite3 \
                texinfo scons genisoimage || echo "Warning: Some packages failed to install."
            set -e
            ;;
        fedora|redhat|centos|rhel)
            verbose "Installing packages with YUM, please wait..."
            sudo yum install $confirm mpfr-devel gmp-devel libmpc-devel \
                sqlite texinfo scons genisoimage || echo "Warning: Some packages failed to install."
            ;;
        osx|mac)
            if type port >/dev/null 2>&1; then
                verbose "Installing packages with macports, please wait..."

                sudo port install mpfr libmpc gmp libiconv sqlite3 texinfo \
                    scons cdrtools wget mtools gnutar nasm || echo "Warning: Some packages failed to install."
            elif type brew >/dev/null 2>&1; then
                verbose "Installing packages with Homebrew, please wait..."

                brew list scons &>/dev/null || brew install scons || echo "Warning: scons installation failed."
                brew list gnu-tar &>/dev/null || brew install gnu-tar || echo "Warning: gnu-tar installation failed."
                brew list wget &>/dev/null || brew install wget || echo "Warning: wget installation failed."
                brew list xorriso &>/dev/null || brew install xorriso || echo "Warning: xorriso installation failed."
                brew list sqlite3 &>/dev/null || brew install sqlite3 || echo "Warning: sqlite3 installation failed."
                brew list mtools &>/dev/null || brew install mtools || echo "Warning: mtools installation failed."
                brew list nasm &>/dev/null || brew install nasm || echo "Warning: nasm installation failed."
                brew list gmp &>/dev/null || brew install gmp || echo "Warning: gmp installation failed."
                brew list mpfr &>/dev/null || brew install mpfr || echo "Warning: mpfr installation failed."
                brew list libmpc &>/dev/null || brew install libmpc || echo "Warning: libmpc installation failed."
                brew list qemu &>/dev/null || brew install qemu || echo "Warning: qemu installation failed."
                brew list e2fsprogs &>/dev/null || brew install e2fsprogs || echo "Warning: e2fsprogs installation failed."
                brew list autoconf &>/dev/null || brew install autoconf || echo "Warning: autoconf installation failed."
                brew list automake &>/dev/null || brew install automake || echo "Warning: automake installation failed."
                brew list gettext &>/dev/null || brew install gettext || echo "Warning: gettext installation failed."

                set +e  # Avoid brew terminating the build due to link failures
                brew link -f gettext  # not linked by default
                brew link -f e2fsprogs
                set -e
            fi
            real_os="osx"
            ;;
        openbsd)
            verbose "Installing packages with pkg_add, please wait..."
            sudo pkg_add scons mtools sqlite cdrtools gmp mpfr libmpc wget sed || echo "Warning: Some packages failed to install."
            ;;
        cygwin|windows|mingw)
            verbose "Please ensure you use Cygwin's 'setup.exe', or some other method, to install the following:"
            verbose " - Python"
            verbose " - GCC & binutils"
            verbose " - libgmp, libmpc, libmpfr"
            verbose " - mkisofs/genisoimage"
            verbose " - sqlite"
            verbose " - patch"
            verbose " - GNU make"
            verbose "You will need to find alternative sources for the following:"
            verbose " - mtools"
            verbose " - scons"

            real_os="cygwin"
            ;;
        arch)
            verbose "Installing packages with pacman, please wait..."
            sudo pacman -S gcc binutils gmp libmpc mpfr sqlite texinfo scons wget cdrtools mtools tar || echo "Warning: Some packages failed to install."
            ;;
        gentoo)
            verbose "Installing packages with emerge, please wait..."
            sudo emerge -v sys-devel/gcc sys-devel/binutils dev-libs/gmp dev-libs/mpc dev-libs/mpfr dev-db/sqlite dev-libs/texinfo dev-util/scons net-misc/wget sys-apps/cdrtools dosfstools/nasm dev-lang/python dev-python/requests dev-util/cmake sys-devel/flex sys-devel/bison dev-util/lcov || echo "Warning: Some packages failed to install."
            ;;
        *)
            verbose "Operating system '$os' is not supported yet."
            verbose "You will need to find alternative sources for the following:"
            verbose " - Python"
            verbose " - GCC & binutils"
            verbose " - libgmp, libmpc, libmpfr"
            verbose " - mkisofs/genisoimage"
            verbose " - sqlite"
            verbose " - mtools"
            verbose " - scons"
            verbose " - wget"
            verbose " - sed"
            verbose
            verbose "If you can modify this script to support '$os', please provide patches."
            ;;
    esac

    shopt -u nocasematch
    
    echo $real_os > $script_dir/.easy_os

    echo

else
    real_os=`cat $script_dir/.easy_os`
fi
