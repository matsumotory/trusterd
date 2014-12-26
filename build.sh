#!/bin/sh

set -e

git submodule init
git submodule update
cd mruby
rake deep_clean
cp -f ../build_config.rb .
rake
cp -p bin/mruby ../bin/trusterd
cd ..
