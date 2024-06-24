#! /bin/bash

FILE=${1:-"~/pd/core-lib/main.pd"}

killall -15 pd &
(sleep .2 && pd $FILE) &
(sleep .5 && aconnect 'APC MINI' 'Pure Data:0' && aconnect 'Pure Data:2' 'APC MINI')
