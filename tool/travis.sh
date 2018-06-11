#!/usr/bin/env bash

set -xe

pushd http_io
pub get
popd

pushd http_browser
pub get
popd

pushd http_node
pub get
popd

pub run grinder:grinder test