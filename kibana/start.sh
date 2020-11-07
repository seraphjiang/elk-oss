#!/bin/sh
# https://docs.docker.com/config/containers/multi-service_container/

# turn on bash's job control
set -m
  
# Start the primary process and put it in the background
/app/elasticsearch-7.8.0/bin/elasticsearch &
  
# Start the helper process
/app/kibana-7.8.0-linux-x86_64/bin/kibana
  
# the my_helper_process might need to know how to wait on the
# primary process to start before it does its work and returns
  
  
# now we bring the primary process back into the foreground
# and leave it there
fg %1