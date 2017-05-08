#!/bin/sh

rm -r build
mkdir build
cd build && \
	cmake -DBUILD_EMULATOR=OFF -DENABLE_OGG=ON -DENABLE_AAC=ON -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF .. && \
	make && \
	mkdir -p $DEVKITPRO/cpp3ds && \
	mkdir -p $DEVKITPRO/cpp3ds/lib && \
	mv lib/* $DEVKITPRO/cpp3ds/lib && \
	cp -r ../include $DEVKITPRO/cpp3ds/ && \
	cp -r ../cmake $DEVKITPRO/cpp3ds/ && \
	echo "Don't forget to setup environment var CPP3DS to $$DEVKITPRO/cpp3ds"
