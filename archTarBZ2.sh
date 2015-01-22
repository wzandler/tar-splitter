#!/bin/bash


# add optional arg for split file
# readd rm split file
# add logging


# write untar script for recompiling 

usage() 
{
    echo "Usage: $0 [-h] <source_directory/> <destination_directory/>"
    exit 2
}

if [ $# = 0 ]; then
	usage
	
elif [ $1 == "-h" ] || [ $1 == "--help" ]; then
    usage
	
elif [ $# != 2 ]; then
    usage

else

	src_dir=$1
	dst_dir=$2
	breakSize=5242880

	MBcount=100
	threshBytes=$((1024 * $MBcount))

	# grab bite sizes from src dir
	du -s ${src_dir}* > /tmp/dus

	# cat /tmp/dus

	# read line by line
	while read line
	do
		# split into file size and name
		size=$(echo $line | cut -f 1 -d ' ' )
		filePath=$(echo $line | cut -f 2- -d ' ')
		fileName=$(echo $filePath | cut -f 2- -d '/')

		echo Src: ${filePath}

		if [ "$size" -lt "$threshBytes" ]; then
			# tar the small file to destination
			echo small
			# echo ${dst_dir}${fileName}
			# echo ${filePath}
			tar -jcf ${dst_dir}${fileName}.tar. ${filePath}

		else 
			# split tar the big files
			echo big
			tar -jcf - ${filePath} | split -b $breakSize - ${dst_dir}${fileName}_parts.tar.bz2 

		fi

		echo


	done < "/tmp/dus"



	# remove tmp file
	# rm -rf /tmp/dus


fi