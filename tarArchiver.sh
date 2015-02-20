#!/bin/bash


usage() 
{
    echo "Usage: $0 [-h] <source_directory/> <destination_directory/>  optional: <tar chunk sizes (in bytes)> <size threshold>"
    exit 2
}


# Default tar chunk size is 3.9 GB
chunk=4187593113
# Default file size threshold splitting
thresh=4294967296

# Deal with flags
while [ "$1" != "" ]; do
	case $1 in
		-s | --source)		shift
							src_dir=$1
							;;
		-d | --destination) shift
							dst_dir=$1
							;;
		-k | --chunk) 		shift
							chunk=$1
							;;
		-t | --thresh)		shift
							thresh=$1
							;;
		-z | --gzip)		shift
							arch_type=$1
							ext="gz"
							;;
		-j | --bz2)			shift
							arch_type=$1
							ext="bz2"
							;;
        -h | --help)  		usage
                        	exit 0
                        	;;
		* )	usage
			exit 1
    esac
    shift
done

# if [ $# = 0 ]; then
# 	usage
# 	exit 0
# fi
	
# if [ $1 == "-h" ] || [ $1 == "--help" ]; then
#     usage
#     exit 0	
# fi

# Set vars
# src_dir=$1
# dst_dir=$2

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
	
		
	if [ -f  ${dst_dir}${fileName}.tar.${ext} ] || [ -f ${dst_dir}${filePath}_parts.tar.${ext}aa ]; then
		echo "---- ${fileName} Tar exists, skipping archive"
		# if file in xargs ls (it exists) prompt if you want to re-tar
		# use prompt from backupgroom

	else
		if [ "$size" -lt "$threshBytes" ]; then
			# tar the small file to destination
			echo "++++ ${fileName} Taring Started at $(date +%Y\/%m\/%d\ %H\:%M)"
			tar -${arch_type}cf ${dst_dir}${fileName}.tar.${ext} ${filePath}
			echo "==== ${fileName} Taring Finished at $(date +%Y\/%m\/%d\ %H\:%M)"

		else 
			# split tar the big files
			echo "++++ ${fileName} Split Taring Starting at $(date +%Y\/%m\/%d\ %H\:%M)"
			tar -${arch_type}cf - ${filePath} | split -b $chunkSize - ${dst_dir}${fileName}_parts.tar.${ext}
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


