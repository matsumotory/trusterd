#!/bin/sh

set -e

git clone https://github.com/mruby/mruby.git
cp -f build_config.rb mruby/.
cd mruby
rake
cp -p bin/mruby ../bin/trusterd
cd ..
