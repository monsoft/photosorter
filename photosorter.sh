#!/bin/bash

# Photosorter
# by Irek 'Monsoft' Pelech
# (c) 2023 https://seniorlinuxadmin.co.uk
#
# Require: jq, curl and exiftool

help() {
cat <<HELP
Photosorter 1.00 (c) 2023 by Irek 'Monsoft' Pelech

Usage: photosorter <input_dir> <output_dir> [-c]

    input_dir   full path to source pictures and videos directory
    output_dir  full path to destination pictures and videos directory
    -c          copy files instead of symlinking
HELP
}

command_exists () {
    type "$1" &> /dev/null ;
}

if [ "$#" -lt 2 ]; then
    help
    exit 1
fi

# Check if required application are installed
for i in jq curl exiftool; do
    if ! command_exists $i; then
        echo "$i not installed !!!"
        exit 1;
    fi
done 

IN_PIC_DIR=$1
OUT_PIC_DIR=$2
PIC_COPY=$3

# Radar.com API key
RADAR_API_KEY=""
PIC_COUNT=0

if [ -z ${IN_PIC_DIR} ]; then
    echo "No input directory provided !!!"
    exit 1
fi

if [ -z ${OUT_PIC_DIR} ]; then
    echo "No output directory provided !!!"
    exit 1
fi

echo -e "\nPhotosorter 1.00 (c) 2023 by Irek 'Monsoft' Pelech" 

for PIC_FILE in $(find ${IN_PIC_DIR} -type f); do
    file -i $PIC_FILE|egrep "image|video" &>/dev/null
    if [ "$?" -ne 0 ]; then
        echo "$PIC_FILE Non image or video file."
        continue
    fi

    EXIF_DATA=($(exiftool -n -p '$GPSLatitude $GPSLongitude $CreateDate' $PIC_FILE 2> /dev/null))
    if [ ${#EXIF_DATA[@]} -eq 0 ]; then
        echo "$PIC_FILE file have no EXIF Data"
        continue
    fi 
    
    LATITUDE=${EXIF_DATA[0]}
    LONGITUDE=${EXIF_DATA[1]}
    PIC_YEAR=$(echo ${EXIF_DATA[2]}|awk -F: '{ print $1 }')
    PIC_MONTH=$(echo ${EXIF_DATA[2]}|awk -F: '{ print $2 }')
    RADAR_API_RESPONCE=$(curl -s "https://api.radar.io/v1/geocode/reverse?coordinates=${LATITUDE},${LONGITUDE}"  -H "Authorization: ${RADAR_API_KEY}")
    
    if [ "$(echo ${RADAR_API_RESPONCE}|jq -r '.meta.code')" -ne 200 ]; then
        echo "Unable to call RADAR API !!!"
        exit 1
    fi

    PIC_COUNTRY=$(echo ${RADAR_API_RESPONCE} | jq -r ".addresses[].country"| tr " " "_")

    echo "$PIC_FILE ..."

    if [ "${PIC_COPY}" = "-c" ]; then
        install -D -m 644 -t ${OUT_PIC_DIR}/${PIC_COUNTRY}/${PIC_YEAR}/${PIC_MONTH}/ -D ${PIC_FILE}
        let "PIC_COUNT++"
    else 
        if [ ! -d "${OUT_PIC_DIR}" ]; then
            mkdir ${OUT_PIC_DIR}
        fi

        if [ ! -d "${OUT_PIC_DIR}/${PIC_COUNTRY}" ]; then
            mkdir ${OUT_PIC_DIR}/${PIC_COUNTRY}
        fi

        if [ ! -d "${OUT_PIC_DIR}/${PIC_COUNTRY}/${PIC_YEAR}" ]; then
            mkdir ${OUT_PIC_DIR}/${PIC_COUNTRY}/${PIC_YEAR}
        fi
         if [ ! -d "${OUT_PIC_DIR}/${PIC_COUNTRY}/${PIC_YEAR}/${PIC_MONTH}" ]; then
            mkdir ${OUT_PIC_DIR}/${PIC_COUNTRY}/${PIC_YEAR}/${PIC_MONTH}
        fi       

        ln -s ${PIC_FILE} ${OUT_PIC_DIR}/${PIC_COUNTRY}/${PIC_YEAR}/${PIC_MONTH}/ 2> /dev/null
        let "PIC_COUNT++"
    fi
done

echo -e "\nJob done !!!\n"
echo -e "Identified ${PIC_COUNT} pictures and videos"

