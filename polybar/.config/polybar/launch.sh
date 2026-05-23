#!/bin/bash

killall -q polybar

polybar mybar-pri 2>&1 | tee -a /tmp/polybar1.log & disown
polybar mybar-sec 2>&1 | tee -a /tmp/polybar2.log & disown
