#!/bin/bash

# write untar script for recompiling 

usage() 
{
    echo "Usage: $0 [-h] <source_directory/> <destination_directory/> <tar chunk sizes (in bytes)>"
    exit 2
}

( if [ $# = 0 ]; then
	usage
	
elif [ $1 == "-h" ] || [ $1 == "--help" ]; then
    usage
	
elif [ $# -gt 3 ]; then
    usage

else
	startTime=$(date +%s);
	echo "==== Starting ============================"
	
	# Set source and destination vars
	src_dir=$1
	dst_dir=$2

	# Default tar chunk size is 5 MB
	chunkSize=${3:-5242880}

	# File size threshold for spliting or not splitting the tar
	MBcount=3
	threshBytes=$((1024 * $MBcount))

	echo "File Size Threshold: ${threshBytes} bytes"
	echo "Tar Parts Size: ${chunkSize} bytes"

	# grab bite sizes from src dir
	echo "==== Building File List =================="
	du -s ${src_dir}* > /tmp/dus
	echo "Done" 

	# read line by line
	echo "==== Taring Files ========================"
	while read line
	do
		# split into file size and name
		size=$(echo $line | cut -f 1 -d ' ' )
		filePath=$(echo $line | cut -f 2- -d ' ')
		fileName=$(echo $filePath | cut -f 2- -d '/')

		if [ "$size" -lt "$threshBytes" ]; then
			# tar the small file to destination
			echo "${fileName} Taring at $(date +%Y\/%m\/%d\ %H\:%M)"
			tar -jcf ${dst_dir}${fileName}.tar.bz2 ${filePath}
			echo "-Finished at $(date +%Y\/%m\/%d\ %H\:%M)"

		else 
			# split tar the big files
			echo "${fileName} Split Taring at $(date +%Y\/%m\/%d\ %H\:%M)"
			echo tar -jcf - ${filePath} | split -b $chunkSize - ${dst_dir}${fileName}_parts.tar.bz2
			echo "-Finished at $(date +%Y\/%m\/%d\ %H\:%M)"

		fi

	done < "/tmp/dus"
	
	echo "==== All tars complete ====================" 

	# remove tmp file
	rm -rf /tmp/dus 
	echo "Temp Files Removed"

	# Calculate run time
	endTime=$(date +%s);
	diff=$(($endTime-$startTime))
	echo "Total Runtime: $(($diff / 60)) minutes and $(($diff % 60)) seconds."


fi ) >& log