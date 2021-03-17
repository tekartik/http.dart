#!/usr/bin/env bash

# Must be ran from root (.travis.yml), will fail otherwise
set -ev

cd http_support
pub get
dart tool/travis.dart