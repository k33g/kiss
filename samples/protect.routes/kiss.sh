#!/bin/sh
#

RC=1
#trap "echo CTRL-C was pressed" 2
trap "exit 1" 2
while [ $RC -ne 0 ] ; do
   golo golo --files ../../src/main/golo/imports/*.golo  humans.golo
   RC=$?
done
