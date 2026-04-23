#!/bin/bash

rm -rf pkg src
find . -maxdepth 1 -name '*.backup.*' -delete
find . -maxdepth 1 -name 'cachyos-*.tar.gz' -delete
find . -maxdepth 1 -name '*cachy.patch' -delete

echo "Cleaned: pkg/, src/, *.backup.* files, and cachyos-*.tar.gz files"
echo "Never remove config"