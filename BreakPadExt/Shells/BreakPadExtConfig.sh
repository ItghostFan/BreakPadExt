#!/bin/bash

specPath=`pwd`
bash $specPath"/BreakPadExt/Shells/BreakPadExtCopy.sh"
bash $specPath"/BreakPadExt/Shells/BreakPadExtModify.sh" \
$specPath"/BreakPadExt/Classes/breakpad/src/client/ios/Breakpad.mm" \
$specPath"/BreakPadExt/Classes/breakpadext/Breakpad.hpp"