#!/bin/sh
~/bin/qara2c < metabook/Building.md > Makefile
make $1

