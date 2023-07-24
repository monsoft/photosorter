# Photosorter
I guess that I'm not alone with having multiple pictures and videos taken by phone and stored in various places (computer drive, NAS, backup in the cloud or even USB stick). Some times ago I tried to sort & group all my pictures and videos but I gave up after some time with headeache. Recently, I came back to this but with idea of using Exif data which is added by my phone to each photo and video which I made. This is where Photosorter were born.

Photosorter use Exif data from pictures and videos to sort and group them based on when and where they were taken. For geolocation purpose, it use https://radar.com API which return lots of data inclusing coutry name.

#### Installation
Just clone this repo on your *nix/Mac.
Install required commandline tools: jq, curl, tr and exiftool.

#### Obtain Radar API key

You need to create account on https://radar.com webiste and obtain free API key. This key looks like `prj_test_pk_.....` or `prj_prod_pk_.....`. This API key must be used to declere the variable `RADAR_API_KEY` in Photosorter code:
```
RADAR_API_KEY="prj_test_pk_....."
```
#### Usage

Help:
```
./photosorter.sh

Photosorter 1.00 (c) 2023 by Irek 'Monsoft' Pelech

Usage: photosorter <input_dir> <output_dir> [-c]

    input_dir   full path to source pictures and videos directory
    output_dir  full path to destination pictures and videos directory
    -c          copy files instead of symlinking
```
Running Photosorter:
```
$ ./photosorter.sh /pictures /our_pictures

Photosorter 1.00 (c) 2023 by Irek 'Monsoft' Pelech
/picturesGRFI9881.MP4 file have no EXIF Data
/pictures/IMG_1163.MOV ...
/pictures/IMG_5032.JPG ...
/pictures/test.txt Non image or video file.

Job done !!!

Identified 2 pictures and videos
```
Checking output directory:
```
$ cd /our_pictures
$ find .
.
./United_Kingdom
./United_Kingdom/2022
./United_Kingdom/2022/06
./United_Kingdom/2022/06/IMG_1163.MOV
./Greece
./Greece/2020
./Greece/2020/08
./Greece/2020/08/IMG_5032.JPG
```
