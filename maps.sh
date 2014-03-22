#!/bin/sh

SRC=./src
ART_SRC=./src/art/src
MAP_OUT=./src/art/maps

cp ${ART_SRC}/*.tmx ${SRC}
cd ${SRC}
tmxs=$(ls *.tmx)
for tmx in ${tmxs}
do
    tmx2lua ${tmx}
done
cd -
# copy all output (.lua) to MAP_OUT
for tmx in $(ls ${SRC}/*.tmx)
do
    # strip dir
    tmx=${tmx##*/}
    # remove tmx extension
    map_long=${tmx%\.*}
    # append lua extension
    out="${map_long}.lua" # there is an actual file named this
    out_short="${map_long%_map}.lua" # this is the destination file name

    # replace all instances of ../ with art/
    sed 's/\.\.\//art\//g' ${SRC}/${out} > ${MAP_OUT}/${out_short}

    # remove map tmx and lua files
    rm ${SRC}/${tmx} ${SRC}/${out}
done
