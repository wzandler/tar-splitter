#!/bin/bash


# add optional arg for split file
# readd rm split file
# add logging


# write untar script for recompiling 

usage() 
{
    echo "Usage: $0 [-h] <source_directory/> <destination_directory/> <tar chunk sizes (in bytes)>"
    exit 2
}

if [ $# = 0 ]; then
	usage
	
elif [ $1 == "-h" ] || [ $1 == "--help" ]; then
    usage
	
# elif [ $# -lt 3 ] || [$# -gt 3]; then
#     usage

else

	src_dir=$1
	dst_dir=$2
	chunkSize=${3:-5242880}

	echo $chunkSize

	MBcount=3
	threshBytes=$((1024 * $MBcount))

	# grab bite sizes from src dir
	du -s ${src_dir}* > /tmp/dus

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
			tar -jcf ${dst_dir}${fileName}.tar.bz2 ${filePath}

		else 
			# split tar the big files
			echo big
			tar -jcf - ${filePath} | split -b $chunkSize - ${dst_dir}${fileName}_parts.tar.bz2 

		fi

		echo


	done < "/tmp/dus"

	# remove tmp file
	rm -rf /tmp/dus 


fi