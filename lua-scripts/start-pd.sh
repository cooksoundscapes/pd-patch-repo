#!/bin/bash

killall -15 pd &
(sleep .2 && pd $1) &
(sleep .5 && aconnect 'APC MINI' 'Pure Data:0' && aconnect 'Pure Data:2' 'APC MINI')