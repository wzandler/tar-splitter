#!/bin/bash


usage() 
{
    echo "Usage: $0 [-h] <source_directory/> <destination_directory/>  optional: <tar chunk sizes (in bytes)> <size threshold>"
    exit 2
}

if [ $# = 0 ]; then
	usage
	exit 0
fi
	
if [ $1 == "-h" ] || [ $1 == "--help" ]; then
    usage
    exit 0	
fi

# Set source and destination vars
src_dir=$1
dst_dir=$2

# Default tar chunk size is 3.9 GB
chunkSize=${3:-4187593113}

# File size threshold for spliting or not splitting the tar
threshBytes=${4:-4294967296}

# echo "File Size Threshold: ${threshBytes} bytes"
# echo "Tar Parts Size: ${chunkSize} bytes"


(
echo $0 starting at $(date)
startTime=$(date +%s);


# grab byte sizes from src dir
echo "++++ Building File List ++++++++++++++++++++++++++++"
du -sb ${src_dir}* > /tmp/dus
echo "==== Building File List Complete ===================" 

# read line by line
echo "**** Begin Taring All Files ************************"
while read line
do
	# split into file size and name
	size=$(echo $line | cut -f 1 -d ' ' )
	filePath=$(echo $line | cut -f 2- -d ' ')
	fileName=$(echo $filePath | rev | cut -f 1 -d '/' | rev)
	# echo 
	# if block check 
		
	if [ -f  ${dst_dir}${fileName}.tar.bz2 ] || [ -f ${dst_dir}${filePath}_parts.tar.bz2aa ]; then
		echo "---- ${fileName} Tar exists, skipping archive"
		# if file in xargs ls (it exists) prompt if you want to re-tar
		# use prompt from backupgroom

	else
		if [ "$size" -lt "$threshBytes" ]; then
			# tar the small file to destination
			echo "++++ ${fileName} Taring Started at $(date +%Y\/%m\/%d\ %H\:%M)"
			tar -jcf ${dst_dir}${fileName}.tar.bz2 ${filePath}
			echo "==== ${fileName} Taring Finished at $(date +%Y\/%m\/%d\ %H\:%M)"

		else 
			# split tar the big files
			echo "++++ ${fileName} Split Taring Starting at $(date +%Y\/%m\/%d\ %H\:%M)"
			tar -jcf - ${filePath} | split -b $chunkSize - ${dst_dir}${fileName}_parts.tar.bz2
			echo "==== ${fileName} Split Taring Finished at $(date +%Y\/%m\/%d\ %H\:%M)"

		fi

	fi

done < "/tmp/dus"

echo "**** All tars completed at $(date +%Y\/%m\/%d\ %H\:%M) ****************" 

# remove tmp file
rm -rf /tmp/dus 
echo "Temp Files Removed"

# Calculate run time
endTime=$(date +%s)
diff=$(($endTime-$startTime))
echo "Done at $(date +%Y\/%m\/%d\ %H\:%M)"
echo "Time Elapsed: $(($diff / 60)) minutes and $(($diff % 60)) seconds."

) &>${dst_dir}/tar-split-log-$(date +%Y%m%d.%H%M)


