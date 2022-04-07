#!/bin/bash

bash BreakPadExtCopy.sh
specPath=`pwd`
bash BreakPadExtModify.sh \
$specPath"/BreakPadExt/Classes/breakpad/src/client/ios/Breakpad.mm" \
$specPath"/BreakPadExt/Classes/breakpadext/Breakpad.hpp"