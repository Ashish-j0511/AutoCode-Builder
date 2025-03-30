#!/bin/bash



if [[ $# -lt 1 ]] 
then
	echo "Enter the FILE NAME you want OR you want ot Edit :"
	read filename
else
	filename=$1
fi


#d = delimeter (ex sepraters by , . ; : ,etc)
#f = file(columms ex id name )
nopath=$(basename "$filename" )
extension=$(echo $nopath |cut -d"." -f2)

declare -a extensions
declare -a languages
declare -a comments

extensions=( c h java )
languages=( c cpp java )
comments=( "//" "@@" "##" )

#-----------------------------------------------------------------------------
function detect_extension_idx(){

	echo  "---------- Extension detection ----------"
	i=0
	for ext in "${extensions[@]}"
	do
	if [[ $extension = $ext ]] 
	then
		extension_idx=$i
		echo "Done"
		#echo "$ext"
		return
	fi
	let i=i+1
	done
	echo "None"
}

deduce_language() {
	echo  ".......Langugae detection......."
	#it takes index number 0,1,2
	#language=${c[0]}

	language="${languages[$extension_idx]}"
	language_idx=$extension_idx
	comment="${comments[$extension_idx]}"
	echo " YOU Selet the $language"
}

function ask_for_language() {
	language='none'

	while [[ "$language" == "none" ]]
	do 
		echo "Please Choose A Programming Language You Want :"
		echo ${languages[@]} | xargs -n1 | sort -u | xargs
		echo "--------------------"
		echo -n " Seleted A language :"
		read l

		#check it on list
		i=0
		for lang in "${languages[@]}"
		do
			if [[ "$l" == "$lang" ]]
			then
				language=$lang
				comment="${comments[$i]}"
				language_idx=$i
				echo "Language ok "
				return
			fi
			let i=i+1
		done
	done

}


detect_header() {
	echo " ------detecting heder-------"
	keyword_line=$(cat $filename |grep -n "This is an automated Headerd " | cut -d":" -f1)

	if [[ $keyword_line == "" ]]
	then
		echo "This file doesn't contain a HEADER "
		header="none"
		echo "None"
	else
		header="ok"
		echo "Done"
	fi
}

function create_header() {
	echo "------creating Headerd------"
	echo "PLease give discription "
	read description

	echo "$comment ===================-----========================" >/tmp/tmp.txt
	echo "$comment This is an automated Headerd " >>/tmp/tmp.txt
	echo "$comment Author             : Your name " >>/tmp/tmp.txt
	echo "$comment Email              : something_gmail.com " >>/tmp/tmp.txt
	echo "$comment File task          : $description " >>/tmp/tmp.txt
	echo "$comment language           : $language " >>/tmp/tmp.txt
	echo "$comment Created At         : $(date)" >>/tmp/tmp.txt
	echo "$comment Last Updated       : $(date)" >>/tmp/tmp.txt
	echo "$comment ===================----========================" >>/tmp/tmp.txt

	this_date=$(date +"%d%m%y_%H%M%S")
	cat $filename >> /tmp/tmp.txt
	cat /tmp/tmp.txt > $filename

	rm /tmp/tmp.txt
}


function update_header() {
	
    echo "------- Updating Date -------"

    # Escape special characters in the date
    new_date=$(date | sed 's/[\/&]/\\&/g')

    # Use sed to replace the "Last Updated" line
    sed -i "/Last Updated/c\\$comment Last Updated       : $new_date" "$filename"

    echo "Done"
}


function add_template() {
	echo -n "----add add_template -----"

	if [[ -f /home/ashish/Desktop/temps/$language ]]
	then
		cat /home/ashish/Desktop/temps/$language >> $filename
		echo "done"
	else
		echo "fail"
	fi


}

#-----------------------------------------------------------------------------

#none is placeholder
extension_idx=none 

detect_extension_idx

#if idx is ! not equl to none 
if [[ ! $extension_idx == "none" ]]
	then
		deduce_language
	else
		ask_for_language
fi



if [[ -f $filename ]]
then
	detect_header
	if [[ "$header" == "none" ]]
	then
		create_header
	else
		update_header
	fi
else
	touch $filename
	create_header
	add_template
fi


cat $filename

if [[ ! -d ./old_versions ]]
then
	mkdir ./old_versions
fi

cp $filename ./old_versions/$this_date-$filename