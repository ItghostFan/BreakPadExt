#!/bin/bash

# examplePath=`pwd`
# logPath=$examplePath"/fetch_google_breakpad.log"
# echo $examplePath >> $logPath
# cd ..
specPath=`pwd`
git -clone https://github.com/google/breakpad.git -b chrome_99 

classesPath=$specPath"/BreakPadExt/Classes"

cd $classesPath

breakpadPathes=(
"breakpad"
"breakpad/src"
"breakpad/src/client"
"breakpad/src/client/ios"
"breakpad/src/client/ios/handler"
"breakpad/src/client/apple"
"breakpad/src/client/apple/Framework"
"breakpad/src/client/mac"
"breakpad/src/client/mac/crash_generation"
"breakpad/src/client/mac/handler"
"breakpad/src/client/mac/sender"
"breakpad/src/common"
"breakpad/src/common/linux"
"breakpad/src/common/mac"
"breakpad/src/google_breakpad"
"breakpad/src/google_breakpad/common"
)
rm -rf $classesPath"/"${breakpadPathes[0]}
for breakpadPath in ${breakpadPathes[@]}
do
    mkdir $breakpadPath
done

breakpadFiles=(
"breakpad/src/client/minidump_file_writer-inl.h"
"breakpad/src/client/minidump_file_writer.h"
"breakpad/src/client/ios/Breakpad.h"
"breakpad/src/client/ios/BreakpadController.h"
"breakpad/src/client/ios/handler/ios_exception_minidump_generator.h"
"breakpad/src/client/apple/Framework/BreakpadDefines.h"
"breakpad/src/client/mac/handler/ucontext_compat.h"
"breakpad/src/client/mac/handler/breakpad_nlist_64.h"
"breakpad/src/client/mac/handler/dynamic_images.h"
"breakpad/src/client/mac/handler/exception_handler.h"
"breakpad/src/client/mac/handler/minidump_generator.h"
"breakpad/src/client/mac/handler/protected_memory_allocator.h"
"breakpad/src/client/mac/handler/mach_vm_compat.h"
"breakpad/src/client/mac/crash_generation/ConfigFile.h"
"breakpad/src/client/mac/sender/uploader.h"
"breakpad/src/common/basictypes.h"
"breakpad/src/common/convert_UTF.h"
"breakpad/src/common/long_string_dictionary.h"
"breakpad/src/common/macros.h"
"breakpad/src/common/md5.h"
"breakpad/src/common/memory_allocator.h"
"breakpad/src/common/scoped_ptr.h"
"breakpad/src/common/string_conversion.h"
"breakpad/src/common/simple_string_dictionary.h"
"breakpad/src/common/using_std_string.h"
"breakpad/src/common/linux/linux_libc_support.h"
"breakpad/src/common/mac/byteswap.h"
"breakpad/src/common/mac/encoding_util.h"
"breakpad/src/common/mac/file_id.h"
"breakpad/src/common/mac/GTMDefines.h"
"breakpad/src/common/mac/GTMLogger.h"
"breakpad/src/common/mac/HTTPMultipartUpload.h"
"breakpad/src/common/mac/HTTPRequest.h"
"breakpad/src/common/mac/macho_id.h"
"breakpad/src/common/mac/macho_utilities.h"
"breakpad/src/common/mac/macho_walker.h"
"breakpad/src/common/mac/scoped_task_suspend-inl.h"
"breakpad/src/common/mac/string_utilities.h"
"breakpad/src/google_breakpad/common/minidump_format.h"
"breakpad/src/google_breakpad/common/minidump_size.h"
"breakpad/src/google_breakpad/common/minidump_exception_mac.h"
"breakpad/src/google_breakpad/common/breakpad_types.h"
"breakpad/src/google_breakpad/common/minidump_cpu_amd64.h"
"breakpad/src/google_breakpad/common/minidump_cpu_arm.h"
"breakpad/src/google_breakpad/common/minidump_cpu_arm64.h"
"breakpad/src/google_breakpad/common/minidump_cpu_mips.h"
"breakpad/src/google_breakpad/common/minidump_cpu_ppc.h"
"breakpad/src/google_breakpad/common/minidump_cpu_ppc64.h"
"breakpad/src/google_breakpad/common/minidump_cpu_sparc.h"
"breakpad/src/google_breakpad/common/minidump_cpu_x86.h"
"breakpad/src/google_breakpad/common/minidump_exception_fuchsia.h"
"breakpad/src/google_breakpad/common/minidump_exception_linux.h"
"breakpad/src/google_breakpad/common/minidump_exception_ps3.h"
"breakpad/src/google_breakpad/common/minidump_exception_solaris.h"
"breakpad/src/google_breakpad/common/minidump_exception_win32.h"
"breakpad/src/client/minidump_file_writer.cc"
"breakpad/src/client/ios/Breakpad.mm"
"breakpad/src/client/ios/BreakpadController.mm"
"breakpad/src/client/ios/handler/ios_exception_minidump_generator.mm"
"breakpad/src/client/mac/crash_generation/ConfigFile.mm"
"breakpad/src/client/mac/handler/breakpad_nlist_64.cc"
"breakpad/src/client/mac/handler/dynamic_images.cc"
"breakpad/src/client/mac/handler/exception_handler.cc"
"breakpad/src/client/mac/handler/minidump_generator.cc"
"breakpad/src/client/mac/handler/protected_memory_allocator.cc"
"breakpad/src/client/mac/sender/uploader.mm"
"breakpad/src/common/convert_UTF.cc"
"breakpad/src/common/long_string_dictionary.cc"
"breakpad/src/common/md5.cc"
"breakpad/src/common/simple_string_dictionary.cc"
"breakpad/src/common/string_conversion.cc"
"breakpad/src/common/mac/encoding_util.m"
"breakpad/src/common/mac/file_id.cc"
"breakpad/src/common/mac/GTMLogger.m"
"breakpad/src/common/mac/HTTPMultipartUpload.m"
"breakpad/src/common/mac/HTTPRequest.m"
"breakpad/src/common/mac/macho_id.cc"
"breakpad/src/common/mac/macho_utilities.cc"
"breakpad/src/common/mac/macho_walker.cc"
"breakpad/src/common/mac/string_utilities.cc"
)
for breakpadFile in ${breakpadFiles[@]}
do
    cp -f $specPath"/"$breakpadFile $classesPath"/"$breakpadFile
done

# cd $examplePath
# echo "Fetch Google BreakPad Done!" >> $logPath
# cd "${PROJECT_DIR}/../BreakPadExt/Classes/breakpad/src"
# echo `pwd` >> $logPath
