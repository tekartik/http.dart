#!/usr/bin/env bash

set -xe

dartanalyzer --fatal-warnings --fatal-infos lib test

# pub run build_runner test
pub run build_runner test -- -p vm,chrome