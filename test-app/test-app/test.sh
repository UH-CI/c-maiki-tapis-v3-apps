#!/bin/bash

COUNT=$1

for i in $(seq 1 $COUNT); do
    echo "hello world"
done

mkdir testdir
echo "hello world" > file.txt
echo "hello world inside" > testdir/inner.txt

tar -cf output.tar testdir file.txt