#!/usr/bin/env bash

avail=$(df -h / | awk 'NR==2 {print $4}')
echo "Disk: $avail"
