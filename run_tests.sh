#!/bin/bash

# Set the output directory for test results
TEST_RESULTS_DIR="./test-results"

# Create the test results directory if it doesn't exist
mkdir -p $TEST_RESULTS_DIR

# Run the tests with the correct PROPATH
_progres -p /workspaces/oe_web_api/src -p /usr/dlc/tty -p /usr/dlc/tty/ablunit.pl -p /usr/dlc/tty/netlib/OpenEdge.Net.pl -p /usr/dlc/tty/OpenEdge.Core.pl -b -p /workspaces/oe_web_api/src/tests/RunAllTests.p -param $TEST_RESULTS_DIR
