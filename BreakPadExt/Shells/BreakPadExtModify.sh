#!/bin/bash

src=$1
dst=$2
						
dstBreakpadStartClassIndex=0
dstBreakpadEndClassIndex=0
dstIndex=0

breakpadClassStartReg="class.*Breakpad.*{"
breakpadClassEndReg="}.*;"

function echoStep () {
    step=$1" "
    length=${#step}
    while (($length < 80))
    do
        step=$step"#"
        length=${#step}
    done
    echo $step
}

echoStep "Remove Breakpad Extension C++ Class"

while read line
do
	dstIndex=$((dstIndex + 1))
	if [[ $dstBreakpadStartClassIndex == 0 ]]
	then
		classFlags=$((`echo $line | grep "$breakpadClassStartReg" | wc -c`))
		if [[ $classFlags > 0 ]]
		then
			dstBreakpadStartClassIndex=$dstIndex
		fi
	else
		classFlags=$((`echo $line | grep "$breakpadClassEndReg" | wc -c`))
		if [[ $classFlags > 0 && $dstBreakpadEndClassIndex == 0 ]]
		then
			dstBreakpadEndClassIndex=$dstIndex
		fi
	fi
done < $dst

if [[ $dstBreakpadStartClassIndex > 0 && $dstBreakpadEndClassIndex > 0 ]]
then
	sed -i '' $dstBreakpadStartClassIndex','$dstBreakpadEndClassIndex'd' $dst
fi

echoStep "Modify Google Breakpad C++ Class"

googleBreakpadHeaderReg=".*Breakpad\.h"
googleBreakpadHeaderIndex=0

srcBreakpadStartClassIndex=0
srcBreakpadEndClassIndex=0
srcIndex=0


while read line
do
	srcIndex=$((srcIndex + 1))
	if [[ $googleBreakpadHeaderIndex == 0 ]]
	then
		headerFlags=$((`echo $line | grep "$googleBreakpadHeaderReg" | wc -c`))
		if [[ $headerFlags > 0 ]]
		then
			googleBreakpadHeaderIndex=$srcIndex
		fi
	fi

	if [[ $srcBreakpadStartClassIndex == 0 ]]
	then
		classFlags=$((`echo $line | grep "$breakpadClassStartReg" | wc -c`))
		if [[ $classFlags > 0 ]]
		then
			srcBreakpadStartClassIndex=$srcIndex
		fi
	else
		classFlags=$((`echo $line | grep "$breakpadClassEndReg" | wc -c`))

		# if [[ $srcBreakpadEndClassIndex == 0 ]]
		# then
		# 	# Save Code To BreakPad Extension
		# 	echo "$line"
		# fi

		if [[ $classFlags > 0 && $srcBreakpadEndClassIndex == 0 ]]
		then
			srcBreakpadEndClassIndex=$srcIndex
		fi
	fi
done < $src

srcIndex=$srcBreakpadEndClassIndex
while (( $srcIndex >= $srcBreakpadStartClassIndex ))
do
	line=`sed $srcIndex'!d;q' $src | sed 's/private:/protected:/g'`
	srcIndex=$((srcIndex - 1))
	echo "$line"
	sed -i '' $((dstBreakpadStartClassIndex - 1))"a\\
$line
	" $dst
done

endLine=`sed $srcBreakpadEndClassIndex'!d;q' $src`
echoStep $endLine
sed -i '' $srcBreakpadEndClassIndex'd' $src
sed -i '' $((srcBreakpadEndClassIndex - 1))"a\\
$endLine */
" $src

startLine=`sed $srcBreakpadStartClassIndex'!d;q' $src`
echoStep $startLine
sed -i '' $srcBreakpadStartClassIndex'd' $src
sed -i '' $((srcBreakpadStartClassIndex - 1))"a\\
/* $startLine
" $src

sed -i '' $((googleBreakpadHeaderIndex))"a\\
#include \"Breakpad.hpp\"
" $src