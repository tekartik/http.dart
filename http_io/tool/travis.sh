#!/usr/bin/env bash

set -xe

dartanalyzer --fatal-warnings lib test

# pub run build_runner test
pub run build_runner test