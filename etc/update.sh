#!/bin/sh

# make sure things are initialized
git submodule update --init --recursive

# make sure latest source is pulled
git submodule foreach git pull origin master
