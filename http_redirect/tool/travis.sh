#!/usr/bin/env bash

set -xe

dartanalyzer bin lib test

# pub run build_runner test
pub run build_runner test -- -p vm -p node -p chrome