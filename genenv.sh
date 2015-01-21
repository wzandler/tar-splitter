#!/bin/bash
# Generates random files for backup testing.
usage() 
{
    echo "Usage: $0 [-h] <Test enviornment directory> "
    exit 2
}

if [ $# = 0 ]; then
	usage
	
elif [ $1 == "-h" ] || [ $1 == "--help" ]; then
    usage

else

	env=$1
	# 100M Files
	for i in {1..3};
		do
			dd if=/dev/urandom of=$env/rand_file_large_${i} bs=104857600 count=1;
		done
	# 10M Files
	for i in {1..5};
		do
			dd if=/dev/urandom of=$env/rand_file_medium_${i} bs=10485760 count=1;
		done
	# 1M Files 
	for i in {1..7};
		do
			dd if=/dev/urandom of=$env/rand_file_small_${i}  bs=1048576 count=1;
		done

	
fi
