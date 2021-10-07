#!/bin/true

export STRAPY_STAGE_NAME="stage2"

. $(dirname $(realpath -s $0))/../lib/build.sh

# Set up stage2 specific requirements
activateStage1Compiler

prepareBuild
