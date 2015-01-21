#!/bin/bash

usage() 
{
    echo "Usage: $0 [-h] <source_directory> <destination_directory>"
    exit 2
}

function dus ()
{
  # SORT ORDER  (true/false)
  ASCENDING=true
  # Create temp file
  touch /tmp/duout
  # mktmp file
  DATA="/tmp/duout"
  # RUN DU
  du -sh $@ >$DATA 2>/dev/null
  # SORT DATA AND OUTPUT
  if $ASCENDING
  then
    for P in K M G
    do
      grep -e "[0-9]$P" $DATA|sort -n
    done

  else
    for P in G M K
    do
      grep -e "[0-9]$P" $DATA|sort -nr
    done
  fi
  #remove datafile
  rm $DATA
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

	# findopts="\! -path '.${src_dir}/lvl*'"

	du
	cat each file size
		K
		M
		G
		T
	get range of sizes 
	cut f2 /t for each type


	echo dus
	# find $src_dir -maxdepth 1 $findopts -type f -size -10M > $src_dir/lvls
	# find $src_dir -maxdepth 1 $findopts -type f -size -100M > $src_dir/lvlm
	# find $src_dir -maxdepth 1 $findopts -type f -size +100M > $src_dir/lvll


	#
	small=$(cat src_dir/lvls | xargs)
	medium=$(grep -v -f $src_dir/lvls $src_dir/lvlm)
	large=$(cat src_dir/lvll | xargs)


	echo $(echo lvls | xargs -n 1)
	echo $(echo $medium | xargs -n 1)
	echo $(echo lvll | xargs -n 1)
fi

#
# Cleanup
#
# rm -rf $src_dir/lvl*

# find d vs. f 
# pull data from du -sh *
# sort script and create new output list
# archive accordingly from there

# find . -maxdepth 1 -type d -size +10M
# find . -maxdepth 1 -type f -size +10M

# cat file | sort -h 


