#!/bin/bash

if [ "$#" -ne 1 ] ; then
  echo "usage: <prog> river-name.json"
  exit 1
fi

river=$1
if [ "${JDBC_IMPORTER_HOME}" = "" ] ; then
 export JDBC_IMPORTER_HOME=<%= @install_path %>
fi

river_pid=$JDBC_IMPORTER_HOME/rivers/${river%.json}.pid

echo "pid file is: $river_pid"

PID=`cat ${river_pid}`

kill $PID
res=$?

if [ $res -eq 0 ] ; then
 echo "Killed river... $1"
else 
 echo "Could not kill river... $1"
fi

exit $res
