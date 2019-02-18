#!/usr/bin/env bash

set -xe

# Test dependecies
pub upgrade

pushd http_io
pub get
tool/travis.sh
popd

pushd http_browser
pub get
tool/travis.sh
popd

pushd http_node
pub get
tool/travis.sh
popd

pushd http_redirect
pub get
tool/travis.sh
popd

pub run grinder:grinder test