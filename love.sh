#!/bin/sh

SRC=src
ART_SRC=src/art/src

CUR=$(pwd)
cd ${SRC}
zip -r starplane.love * -x art/src/*
cd ${CUR}
mv ${SRC}/starplane.love ${CUR}/
