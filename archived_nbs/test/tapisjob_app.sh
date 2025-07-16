#!/usr/bin/env bash

# tapisjob_app.sh is what tapis searches for to execute a job. 
# It is where you coordinate your application, call other scripts, etc.

DEBUG_LOG="./script_debug.log"

echo "Starting script at $(date)" > "$DEBUG_LOG"

source ~/.bashrc

# This will print to output/tapisjob.out
echo "Hello world from tapisjob_app"

# This will print to output/tapisjob.out as well
./test/test.sh "Hello from test.sh"

echo "Ending script at $(date)" >> "$DEBUG_LOG"
