#!/bin/bash

# Delete all .com and .flp files in the current directory
find . -maxdepth 1 -type f \( -name "*.com" -o -name "*.flp" \) -exec rm {} \;
