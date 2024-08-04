#!/bin/bash
cd ${0%/*}

# Sync copy from private repo to public repo

delete=--delete
test=
verbose=
# test=--dry-run
verbose=v

excludes="--exclude-from to-public-exclude.txt"

source=../

destRepo=98-MoGallery
rpath=../../$destRepo

echo $verbose $delete $test
echo "rsync from $source"
echo "        to $rpath"
rsync -razO$verbose $excludes $delete $test "$source/" "$rpath/"
