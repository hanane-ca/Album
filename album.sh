#!/bin/bash
mkdir -p $2

#bottom of html file
endHtml(){
	echo "</body>
         </html>" >> $1
}

#start of html file
startHtml(){
	echo "<!DOCTYPE html>
	<html>
	<head>
	<title>titre</title>
	</head>
	<body>" > $1
}

#create the main html file
htmlSource(){
touch index.html $1
startHtml "index.html"
for d in $(find . -mindepth 1 -maxdepth 1 -type d) 
do   
	#to do number
	echo '<a href='$d/index.html'>' "$d-thumb.jpg : number" '</a>' >> index.html
done
endHtml "index.html"
}

#create sub html files
html_sub_index(){
for d in $(find . -mindepth 1 -maxdepth 1 -type d) 
do   
	touch index.html $d
	startHtml "$d/index.html"
	for f in $(find $d -type f -name "*.jpg")
	do
		echo '<a href='$f'>' <img src="$d/.thumbs/"${f%.jpg}-thumb.jpg"> '</a>' >> $d/index.html
	done
	endHtml "$d/index.html"
done
}

#create hierarchy
for filename in $1/*.jpg; do
	#get the date from each photo
    DATEBITS=( $(exiftool -CreateDate -FileModifyDate -DateTimeOriginal "$filename" | awk -F: '{ print $2 ":" $3 ":" $4}' |
     sed 's/+[0-9]*//' | sort | grep -v 1970: | cut -d: -f1-6 | tr ':' ' ' | head -1) )
    YR=${DATEBITS[0]}
    MTH=${DATEBITS[1]}
    DAY=${DATEBITS[2]}
    #create year dir
    mkdir -p $2/$YR
    date="$YR-$MTH-$DAY"
    #create date dir inside year dir
    mkdir -p $2/$YR/$date
    newName= "$date-${filename%.jpg}"
    #rename photos
    mv $filename newName
    #copier les images dans le dossier correspondant
    cp "$date-$filename" $2/$YR/$date
    #create thumb file
    mkdir .thumbs
    #compress image
    convert  $newName -resize x150 "$newName-thumb.jpg"
    #copier l'image compressée dans le dossier thumbs
    mv "$newName-thumb.jpg" $2/$YR/$date/.thumbs
done

cd $2
#creer le fichier html de base
htmlSource "$2"
#creer les sous fichiers html
html_sub_index