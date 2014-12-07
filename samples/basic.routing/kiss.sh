#!/bin/sh
#

RC=1
#trap "echo CTRL-C was pressed" 2
trap "exit 1" 2
while [ $RC -ne 0 ] ; do
   golo golo --classpath jars/*.jar --files src/main/golo/libs/*.golo src/main/golo/app/*.golo src/main/golo/app/models/*.golo src/main/golo/app/controllers/*.golo src/main/golo/app/libs/*.golo src/main/golo/main.golo
   RC=$?
done
