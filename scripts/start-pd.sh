#!/bin/bash

pd $1 &
(sleep 1 && ~/scripts/apc-connect.sh)