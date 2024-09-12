#!/bin/bash

files=$(ls /_so)

for file in $files
do
    cp /_so/$file /usr/lib/x86_64-linux-gnu/$file
    echo $file
done
