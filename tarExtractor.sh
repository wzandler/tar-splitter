#!/bin/bash

// Take tar file from input and unarchive to destination


usage() 
{
    echo "Usage: $0 [-h] <extraction_file> <destination_directory/>"
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

ext_file=$1
dst_dir=$2



cat ${ext_file}_parts.tar.bz2* | tar -jxf - -C ${dst_dir}
