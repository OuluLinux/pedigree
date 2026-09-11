#!/bin/bash

# Run pup, and install pup if it is not present.

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

PUP_TMP="$DIR/scripts/pup.whl.tmp"
PUP="$DIR/scripts/pup.whl"

# Parse command line arguments to check for quiet mode
QUIET_MODE=0
for arg in "$@"; do
    case $arg in
        -q|--quiet)
            QUIET_MODE=1
            ;;
    esac
done

set +e

try_update_pup()
{
    if [ $QUIET_MODE -eq 0 ]; then
        curl -o ".pup-version-new" https://pup.pedigree-project.org/pup-version
    else
        curl -o ".pup-version-new" https://pup.pedigree-project.org/pup-version >/dev/null 2>&1
    fi
    if cmp --silent ".pup-version-new" ".pup-version"; then
        rm -f ".pup-version-new"
    else
        if [ $QUIET_MODE -eq 0 ]; then
            curl -o "$PUP_TMP" https://pup.pedigree-project.org/pup.whl && \
                mv "$PUP_TMP" "$PUP" && mv ".pup-version-new" ".pup-version"
        else
            curl -o "$PUP_TMP" https://pup.pedigree-project.org/pup.whl >/dev/null 2>&1 && \
                mv "$PUP_TMP" "$PUP" && mv ".pup-version-new" ".pup-version"
        fi
    fi
}

# Download pup for the first time if we don't know what version we have.
if [ ! -e .pup-version ]; then
    if [ $QUIET_MODE -eq 0 ]; then
        echo "Checking for pup updates..."
    fi
    try_update_pup
fi

# Update pup if needed.
if test $(find .pup-version -maxdepth 1 -mmin +120); then
    if [ $QUIET_MODE -eq 0 ]; then
        echo "Checking for pup updates..."
    fi
    try_update_pup
fi

set -e

python3 - <<'PY'
import importlib
import subprocess
import sys

try:
    importlib.import_module('requests')
except ImportError:
    try:
        importlib.import_module('pip')
    except ImportError:
        import ensurepip
        ensurepip.bootstrap()
    in_venv = sys.prefix != getattr(sys, "base_prefix", sys.prefix)
    pip_cmd = [sys.executable, "-m", "pip", "install"]
    if not in_venv:
        pip_cmd.append("--user")
    pip_cmd.append("requests")
    subprocess.check_call(pip_cmd)
PY

# Strip -q and --quiet flags before passing to pedigree_updater, since it doesn't recognize them
stripped_args=()
for arg in "$@"; do
    case $arg in
        -q|--quiet)
            # Skip these flags - we handle quiet mode in this script
            ;;
        *)
            stripped_args+=("$arg")
            ;;
    esac
done

# Pass the remaining arguments to the Python script
python3 "$PUP/pedigree_updater" --config="$DIR/scripts/pup/pup.conf" "${stripped_args[@]}"
