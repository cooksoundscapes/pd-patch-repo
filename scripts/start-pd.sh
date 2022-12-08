#!/bin/bash

killall -15 pd &
(sleep .2 && pd $1) &
(sleep 1 && ~/scripts/apc-connect.sh)