.PHONY: map love

SRC=src
ART_SRC=src/art/src
MAP_OUT=src/art/levels

maps:
	./maps.sh

love: maps
	./love.sh
