#!/bin/bash

input=$1

function restoreFile() {

	rm -r $restore_path 2> /dev/null # remove existing if overwriting
	mkdir -p ${restore_path%/*} # create directories
	mv ~/recyclebin/$input ${restore_path%/*}

	grep -v $input ~/.restore.info > ~/tmp_file
	mv ~/tmp_file ~/.restore.info
	echo "File restored"

	new_name=$(echo $restore_path | rev | cut -d'/' -f1 | rev)
	mv "${restore_path%/*}/$input" "${restore_path%/*}/$new_name"
}

if [ -z $input ] 
then
	echo "restore: no filename provided"
	exit 1
elif [ ! -e ~/recyclebin/$input ]
then 
	echo "restore: cannot restore '$input': No such file"
else 
	restore_path=$(grep -w $input ~/.restore.info | cut -d: -f2)
	if [ -f $restore_path ] 2> /dev/null
	then 
		echo "Do you want to overwrite? y/n "
		read confirm
		confirm=$( echo $confirm | tr [:upper:] [:lower:] | cut -c1)
		if [ $confirm != 'y' ]
		then 
			echo "File not restored"
			exit 1
		else
			restoreFile
		fi
	else
		restoreFile
	fi
fi