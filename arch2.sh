#!/bin/bash

usage() 
{
    echo "Usage: $0 [-h] <source_directory> <destination_directory>"
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

	# grab bite sizes from src dir
	du -s ${src_dir}/* > /tmp/dus

	echo dus

	# read line by line
	while read line
	do
		size=$(echo line | cut -f 1)
		file=$(echo line | cut -f 2-)

		if [ $size -ge 100 ]; then
			echo large
		elif [ $size -ge 10 ] && [ $size -lt 100 ]; then
			echo medium
		else 
			echo small
		fi
			



	done < /tmp/dus
fi