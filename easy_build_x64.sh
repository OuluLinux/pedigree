#!/bin/bash

# Script that can be run to set up a Pedigree repository for building with minimal
# effort.

# TODO: fix this up as it's currently in the middle of migrating from scons -> cmake

# Use English locale for consistent error messages
export LC_ALL=C.UTF-8

old=$(pwd)
script_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P) && script_dir=$script_dir
cd $old

COMPILER_DIR=$script_dir/pedigree-compiler
. $script_dir/build-etc/travis.sh

set -e

. $script_dir/scripts/easy_build_deps.sh

echo "Please wait, checking for a working cross-compiler."
echo "If none is found, the source code for one will be downloaded, and it will be"
echo "compiled for you."

# Special parameters for some operating systems when building cross-compilers
case $real_os in
    osx)
        compiler_build_options="$compiler_build_options osx-compat"
        ;;
esac

# Install cross-compilers
$script_dir/scripts/checkBuildSystemNoInteractive.pl x86_64-pedigree $COMPILER_DIR $compiler_build_options


old=$(pwd)

# Fix up POSIX headers which sometimes get a recursive symlink.
rm -f src/subsys/posix/include/include || true


git submodule update --init --recursive


set +e


# Update the local working copy only if it is clean.
changed=`git status -s -uno`
if [ -z "$changed" ]; then
    git pull --rebase > /dev/null 2>&1
fi

if [ -d "src/modules/drivers/cdi" ]; then
    cd src/modules/drivers/cdi
    git pull || echo "Failed to update cdi."
    cd ${old}
else
    git clone https://git.tyndur.org/lowlevel/cdi.git src/modules/drivers/cdi || echo "Failed to clone cdi, cdi will not be part of your build."
fi

set -e




# Build Pedigree.
mkdir -p build-host && cd build-host
cmake $TRAVIS_OPTIONS ..
make
cd ..

mkdir -p build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../build-etc/cmake/pedigree_amd64.cmake -DIMPORT_EXECUTABLES=../build-host/HostUtilities.cmake $TRAVIS_OPTIONS ..

# Build libc/libm only if it hasn't been built already
if [ ! -f "../build/musl/lib/libc.so" ] || [ ! -f "../build/musl/lib/libc.a" ]; then
    echo "Building libc/libm..."
    make libc
else
    echo "libc/libm already built. Skipping."
fi
cd ..



echo
echo "Configuring the Pedigree UPdater..."

$script_dir/setup_pup.py amd64

# Try to sync packages, but continue if the server is unreachable
$script_dir/run_pup.sh sync || echo "Warning: Could not sync packages from server. Continuing with build..."

# Needed for libc
$script_dir/run_pup.sh install ncurses || echo "Warning: Could not install ncurses from server. Continuing with build..."

# Pull down libtool.
if ! $script_dir/run_pup.sh install libtool; then
    echo "Warning: Could not install libtool from server. Attempting to build from source..."

    # Try to build libtool from source
    if [ -f "$script_dir/scripts/build-libtool.sh" ]; then
        echo "Building libtool from source..."
        # Create external directory for libtool build
        mkdir -p "$script_dir/external"
        # Build libtool with appropriate parameters
        SRCDIR="$script_dir" TARGETDIR="$script_dir/../images/local" bash "$script_dir/scripts/build-libtool.sh"
    else
        echo "libtool build script not found. Continuing without libtool..."
    fi
fi


# Enforce using our libtool.
export LIBTOOL=$script_dir/../images/local/applications:$PATH


# Build GCC again with access to the newly built libc.
# This will create a libstdc++ that can be used by pedigree-apps to build GCC
# again, this time with a shared libstdc++. pedigree-apps should then build GCC
# again to build it against the shared libstdc++. Once a working shared
# libstdc++ exists, the static one built here is no longer relevant.
# What a mess!
$script_dir/scripts/checkBuildSystemNoInteractive.pl x86_64-pedigree $COMPILER_DIR $compiler_build_options "libcpp"

set +e

echo
echo "Ensuring CDI is up-to-date."

# Setup all submodules, make sure they are up-to-date
git submodule init > /dev/null 2>&1
git submodule update > /dev/null 2>&1

echo
echo "Installing a base set of packages..."

$script_dir/run_pup.sh install pedigree-base || echo "Warning: Could not install pedigree-base. Some functionality may be missing."
$script_dir/run_pup.sh install libpng || echo "Warning: Could not install libpng. Some functionality may be missing."
$script_dir/run_pup.sh install libfreetype || echo "Warning: Could not install libfreetype. Some functionality may be missing."
$script_dir/run_pup.sh install libiconv || echo "Warning: Could not install libiconv. Some functionality may be missing."
$script_dir/run_pup.sh install zlib || echo "Warning: Could not install zlib. Some functionality may be missing."

$script_dir/run_pup.sh install bash || echo "Warning: Could not install bash. Some functionality may be missing."
$script_dir/run_pup.sh install coreutils || echo "Warning: Could not install coreutils. Some functionality may be missing."
$script_dir/run_pup.sh install fontconfig || echo "Warning: Could not install fontconfig. Some functionality may be missing."
$script_dir/run_pup.sh install pixman || echo "Warning: Could not install pixman. Some functionality may be missing."
$script_dir/run_pup.sh install cairo || echo "Warning: Could not install cairo. Some functionality may be missing."
$script_dir/run_pup.sh install expat || echo "Warning: Could not install expat. Some functionality may be missing."
$script_dir/run_pup.sh install mesa || echo "Warning: Could not install mesa. Some functionality may be missing."
$script_dir/run_pup.sh install gettext || echo "Warning: Could not install gettext. Some functionality may be missing."

$script_dir/run_pup.sh install pango || echo "Warning: Could not install pango. Some functionality may be missing."
$script_dir/run_pup.sh install glib || echo "Warning: Could not install glib. Some functionality may be missing."
$script_dir/run_pup.sh install libpcre || echo "Warning: Could not install libpcre. Some functionality may be missing."
$script_dir/run_pup.sh install harfbuzz || echo "Warning: Could not install harfbuzz. Some functionality may be missing."
$script_dir/run_pup.sh install libffi || echo "Warning: Could not install libffi. Some functionality may be missing."
$script_dir/run_pup.sh install dialog || echo "Warning: Could not install dialog. Some functionality may be missing."

# Install GCC to pull in shared libstdc++.
$script_dir/run_pup.sh install gcc || echo "Warning: Could not install gcc. Some functionality may be missing."

set -e

echo
echo "Beginning the Pedigree build."
echo

# Build full kernel
cd build
make

cd "$old"

echo
echo
echo "Pedigree is now ready to be built without running this script."
echo "To build in future, run the following command in the '$script_dir' directory:"
echo "scons"
echo
echo "If you wish, you can continue to run this script. It won't ask questions"
echo "anymore, unless you remove the '.easy_os' file in '$script_dir'."
echo
echo "You can also run scons --help for more information about options."
echo
echo "Patches should be posted in the issue tracker at http://pedigree-project.org/projects/pedigree/issues"
echo "Support can be found in #pedigree on irc.freenode.net."
echo
echo "Have fun with Pedigree! :)"

