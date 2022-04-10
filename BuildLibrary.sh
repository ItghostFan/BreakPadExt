#!/bin/bash

# Usage:
# bash BuildLibrary.sh scheme project


function echoStep () {
    step="### "$1" "
    length=${#step}
    while (($length < 80))
    do
        step=$step"#"
        length=${#step}
    done
    echo $step
}

currentDir=`pwd`

inputCount=$#
scheme=""
project=""

if [[ $inputCount > 0 ]]
then
	echo $*
else
	project=`ls | grep -i ".xcodeproj"`
	scheme=${project%.*}
fi

echoStep "Get TARGET_BUILD_DIR"
simulatorBuildDir=`xcodebuild -project $project -sdk iphonesimulator -showBuildSettings | grep "TARGET_BUILD_DIR"`
simulatorBuildDir=${simulatorBuildDir##* }

iphoneBuildDir=`xcodebuild -project $project -sdk iphoneos -showBuildSettings | grep "TARGET_BUILD_DIR"`
iphoneBuildDir=${iphoneBuildDir##* }

echo "Simulator Build Dir $simulatorBuildDir"
echo "iPhone Build Dir $iphoneBuildDir"

echoStep "Clean Last Simulator Build"

xcodebuild clean -project $project -scheme $scheme -sdk iphonesimulator -configuration Release

echoStep "Clean Last iPhone Build"

xcodebuild clean -project $project -scheme $scheme -sdk iphoneos -configuration Release

echoStep "Build Simulator Target"

xcodebuild -project $project -scheme $scheme -sdk iphonesimulator -configuration Release

echoStep "Build iPhone Target"

xcodebuild -project $project -scheme $scheme -sdk iphoneos -configuration Release

simulatorResults=(`ls $simulatorBuildDir`)
iphoneResults=(`ls $iphoneBuildDir`)

simulatorLibs=()
simulatorLibIncludes=()
simulatorFrameworks=()
simulatorDSYMs=()

iphoneLibs=()
iphoneLibIncludes=()
iphoneFrameworks=()
iphoneDSYMs=()

fatLibs=()

for file in ${simulatorResults[@]}
do
	if [[ $((`echo $file | grep -i "\.a$" | wc -c`)) > 0 ]]
	then
		simulatorLibs[${#simulatorLibs[@]}]=$simulatorBuildDir"/"$file
		iphoneLibs[${#iphoneLibs[@]}]=$iphoneBuildDir"/"$file

		fatLibs[${#fatLibs[@]}]=$file
	elif [[ $((`echo $file | grep -i "\.framework$" | wc -c`)) > 0 ]]
	then
		simulatorFrameworks[${#simulatorFrameworks[@]}]=$simulatorBuildDir"/"$file
		iphoneFrameworks[${#iphoneFrameworks[@]}]=$iphoneBuildDir"/"$file
	elif [[ $((`echo $file | grep -i "\.dSYM$" | wc -c`)) > 0 ]]
	then
		simulatorDSYMs[${#simulatorDSYMs[@]}]=$simulatorBuildDir"/"$file
		iphoneDSYMs[${#iphoneDSYMs[@]}]=$iphoneBuildDir"/"$file
	else
		simulatorLibIncludes[${#simulatorLibIncludes[@]}]=$simulatorBuildDir"/"$file
		iphoneLibIncludes[${#iphoneLibIncludes[@]}]=$iphoneBuildDir"/"$file
	fi
done

# for framework in ${simulatorFrameworks[@]}
# do
# 	echo $framework
# done

# for lib in ${simulatorLibs[@]}
# do
# 	echo $lib
# done

# for libInclude in ${simulatorLibIncludes[@]}
# do
# 	echo $libInclude
# done

# zip -r "lib"$scheme".zip" ${simulatorLibIncludes[@]} ${simulatorLibs[@]}

echoStep "Make Fat Library & Dylib"

libDir="lib"
dylibDir="dylib"
rm -rf $libDir $dylibDir

libProjectDir="lib/$scheme"
dylibProjectDir="dylib/$scheme"
mkdir -p $libProjectDir $dylibProjectDir

fatLibIndex=0

while (( $fatLibIndex < ${#simulatorLibs[@]} ))
do
	lipo -output $libProjectDir"/"${fatLibs[$fatLibIndex]} -create ${simulatorLibs[$fatLibIndex]} ${iphoneLibs[$fatLibIndex]}
	fatLibIndex=$((fatLibIndex + 1))
done

for iphoneLibInclude in ${iphoneLibIncludes[@]}
do
	includeFile=${iphoneLibInclude##*/}
	cp -rf $iphoneLibInclude $libProjectDir"/"$includeFile
done

fatDylibIndex=0

while (( $fatDylibIndex < ${#simulatorFrameworks[@]} ))
do
	dylibName=${simulatorFrameworks[$fatDylibIndex]}
	dylibName=${dylibName%.*}
	dylibName=${dylibName##*/}

	simulatorDylib=${simulatorFrameworks[$fatDylibIndex]}"/"$dylibName
	iphoneDylib=${iphoneFrameworks[$fatDylibIndex]}"/"$dylibName

	cp -rf ${iphoneFrameworks[$fatDylibIndex]} "$dylibProjectDir/$dylibName.framework"

	fatDstPath="$dylibProjectDir/$dylibName.framework/$dylibName"

	rm -rf $fatDstPath

	lipo -output $fatDstPath -create $simulatorDylib $iphoneDylib

	fatDylibIndex=$((fatDylibIndex + 1))
done

fatDSYMIndex=0

while (( $fatDSYMIndex < ${#simulatorDSYMs[@]} ))
do
	dSYMName=${simulatorDSYMs[$fatDSYMIndex]}
	dSYMName=${dSYMName%%.*}
	dSYMName=${dSYMName##*/}

	simulatorDSYM="${simulatorDSYMs[$fatDSYMIndex]}/Contents/Resources/DWARF/$dSYMName"
	iphoneDSYM="${iphoneDSYMs[$fatDSYMIndex]}/Contents/Resources/DWARF/$dSYMName"

	fatDstPath="$dylibProjectDir/$dSYMName.framework.dSYM/Contents/Resources/DWARF/$dSYMName"

	cp -rf ${iphoneDSYMs[$fatDSYMIndex]} "$dylibProjectDir/$dSYMName.framework.dSYM"

	rm -rf $fatDstPath

	lipo -output $fatDstPath -create $simulatorDSYM $iphoneDSYM

	fatDSYMIndex=$((fatDSYMIndex + 1))

done

echoStep "Zip Fat Library & Dylib"

binDir="bin"
tmpDir="$binDir/tmp"

rm -rf $binDir
mkdir -p $tmpDir

libSrcs=`ls -d $libProjectDir"/"`
dylibSrcs=`ls -d $dylibProjectDir"/"`

cp -rf ${libSrcs[@]} ${dylibSrcs} "$tmpDir/"

cd $tmpDir

zipFiles=`ls`

currentTime=`date "+%Y_%m_%d_%H_%M_%S"`

zipFile="$scheme-$currentTime.zip"

zip $zipFile -r ${zipFiles[@]}

cp -rf $zipFile "../"

cd $currentDir
rm -rf $tmpDir

echoStep "All Done!"




