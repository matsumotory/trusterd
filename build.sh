#!/bin/sh

set -e

git submodule init
git submodule update
cp -f build_config.rb mruby/.
cd mruby
rake
cp -p bin/mruby ../bin/trusterd
cd ..
