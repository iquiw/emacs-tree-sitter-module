#! /bin/bash

set -euo pipefail

CC=cc
LDFLAGS='-shared'
SUFFIX=

case $(uname -s) in
MINGW*)	SUFFIX=dll ;;
*)	SUFFIX=so ;;
esac

build() {
	local dir=$1
	local lang=$2
	local dest=$3

	pushd "$dir" >/dev/null

	$CC -fPIC -c -I. parser.c

	if [ -f scanner.c ]; then
		$CC -fPIC -c -I. scanner.c
	elif [ -f scanner.cc ]; then
		CC=c++
		$CC -fPIC -I. -c scanner.cc
		if [ "$MSYSTEM" = UCRT64 ]; then
			LDFLAGS="-static-libstdc++ $LDFLAGS"
		fi
	fi

	echo $CC -fPIC $LDFLAGS ./*.o -o "$dest/libtree-sitter-${lang}.${SUFFIX}"
	$CC -fPIC $LDFLAGS ./*.o -o "$dest/libtree-sitter-${lang}.${SUFFIX}"

	popd >/dev/null
}

copy_license() {
	local dir=$1

	license="$dir/LICENSE"
	if [ -f "$dir/LICENSE.md" ]; then
		license="$dir/LICENSE.md"
	elif [ ! -f "$license" ]; then
	     return
	fi
	if [ "$dir" = . ]; then
		cp "$license" "../dist/licenses/LICENSE-$lang"
	else
		cp "$license" "dist/licenses/LICENSE-$lang"
	fi
}

dir=$1
if [ "$dir" = . ]; then
	lang=$(pwd)
	lang=${lang##*/}
else
	lang=$dir
fi
if [ "$#" -eq 2 ]; then
	subdir=$2
else
	subdir=src
fi

echo -n "Building $lang... "

dest=$PWD/dist
build "$dir/$subdir" "$lang" "$dest"

copy_license "$dir"

echo "done."
