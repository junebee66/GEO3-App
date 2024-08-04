#!/bin/bash
cd ${0%/*}

# Remove all change history from target repo

# /Users/jht2/Documents/projects/xxx/98-MoGallery-Private-private
# https://github.com/xxx/98-MoGallery-Private-private.git
# https://github.com/mobilelabclass-itp/98-MoGallery-Private.git

repo_name=98-MoGallery
repo_dir=98-MoGallery
# repo=covid19-dashboard-private

dest=../$repo_dir

if [ ! -e "$dest" ]; then
  echo "no $dest"
	exit 0
fi

cd $dest

# Prevent accidental use
exit 0

rm -rf .git
git init
git add .
git commit -m 'init'
git remote add origin https://github.com/mobilelabclass-itp/${repo_name}.git
git push --force --set-upstream origin main
