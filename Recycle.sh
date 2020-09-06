#!/bin/bash

option=''
while getopts ":ivr" opt
do 
	option="${option}$opt"
	case ${opt} in
		i) opt_i=1 ;;
		v) opt_v=1 ;;
		r) opt_r=1 ;;
		\?) echo "recycle: invalid option -- '$OPTARG'"
			exit 1 ;;
	esac
done

shift $(($OPTIND - 1))

mkdir -p ~/recyclebin 

function recycleFunction() {
	recycle_name="$(echo $i | rev | cut -d'/' -f1 | rev)_$(ls -i "$i" 2>/dev/null | cut -d' ' -f1 )"
	echo "$recycle_name:$(readlink -e "$i")"
	echo "$recycle_name:$(readlink -e "$i")" >> ~/.restore.info
	mv "$i" $recycle_name  2>/dev/null
	mv $recycle_name ~/recyclebin  2>/dev/null
}

if [ $# -eq 0 ] # no argument
then
	echo "recycle: missing operand"
	exit 1
fi

for i in $@
do
	if [ ! -e "$i" ] # file name not found
	then
		echo "recycle: cannot remove '"$i"': No such file or directory"
	elif [ -d "$i" ] # argument is directory
	then 
		if [ $opt_r == 1 ] 2>/dev/null # -r option is selected
		then
			find $1 -type f -exec recycle -$option {} \;
			find $1 -type d -empty -delete
		else
			echo "recycle: cannot remove '"$i"': Is a directory"
		fi
	elif [ "$(readlink -e $i"")" = "$(readlink -e ~/project/recycle)" ] # trying to delete recycle script
	then
		echo “Attempting to delete recycle – operation aborted” 
	else
		file_name=$(echo $i | cut -d' ' -f1)
		if [ $opt_i == 1 ] 2>/dev/null # -i option is selected
		then 
			echo "recycle: remove file $file_name? "
			read confirm
			confirm=$( echo $confirm | tr [:upper:] [:lower:] | cut -c1)
			if [ "$confirm" = 'y' ] 
			then 
				recycleFunction
			else
				echo "File not removed"
				exit 1
			fi
		fi

		if [ $opt_v == 1 ] 2>/dev/null # -v option is selected
		then
			recycleFunction
			echo "Removed $(echo $file_name | rev | cut -d'/' -f1 | rev)"
		fi

		if [[ $opt_i != 1 && $opt_v != 1 ]] 2>/dev/null # no option selected
		then
			recycleFunction
		fi
	fi
done