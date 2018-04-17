#!/bin/sh
set -e

executable_p() { command -v "$1" >/dev/null 2>&1; }
die() { echo "$1" >&2; exit 1; }

if executable_p wget; then dl() { wget -q $1 -O $2; }
elif executable_p curl; then dl() { curl $1 -o $2; }
else die "no program to fetch remote urls found"
fi

mkdir -p bootstrap
prefix=$PWD/bootstrap

true && {
    url=http://caml.inria.fr/pub/distrib/ocaml-4.06/ocaml-4.06.1.tar.xz
    xz=$(basename $url)
    test -e $xz || dl $url $xz
    tar xf $xz
    cd ${xz%.tar.xz}
    ./configure -prefix $prefix
    make -j4 world -s
    make install
    cd ..
}

cd ..
test -d mupdf || {
    rmudir=$HOME/x/rcs/git/mupdf
    if test -d $rmudir ; then
        ref="--reference $rmudir"
    else
        ref=""
    fi
    git clone --recursive $ref git://git.ghostscript.com/mupdf.git
    cd mupdf
    git checkout 4a7822d6750ecb6e0b63f4357738dc20ecaa58f6
    git submodule update --recursive
    cd -
    make -C mupdf build=native -j4 libs
}
PATH=$prefix/bin:$PATH sh ./build.sh build-strap