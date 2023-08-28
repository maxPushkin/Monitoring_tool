#!/bin/bash

elastic_IP=$ELASTIC_IP
cpu_threshold=90
ram_threshold=90
disk_threshold=90
response_code=200
cpu_flag=0
ram_flag=0
disk_flag=0
response_int_flag=0
# response_ext_flag=0
log_file="/var/log/monitor_resources"

while true
do
  # Get CPU usage
  cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

  # Get RAM usage
  ram=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')

  # Get Disk usage for root partition
  disk=$(df / --output=pcent | tail -n 1 | tr -d '% ' )

  # Get response code for localhost
  response_int=$(curl -o /dev/null -s -w "%{http_code}\n" http://localhost/)

  # Get response code for elastic IP
  response_ext=$(curl -o /dev/null -s -w "%{http_code}\n" http://$elastic_IP/)

  # Check CPU usage
  if [ $(echo "$cpu >= $cpu_threshold" | bc -l) -eq 1 ]; then
    if [ $cpu_flag -eq 0 ]; then
      echo "$(date): CPU crossed 90%: $cpu%" >> $log_file
      cpu_flag=1
    fi
  else
    if [ $cpu_flag -eq 1 ]; then
      echo "$(date): CPU went below 90%" >> $log_file
      cpu_flag=0
    fi
  fi

  # Check RAM usage
  if [ $(echo "$ram >= $ram_threshold" | bc -l) -eq 1 ]; then
    if [ $ram_flag -eq 0 ]; then
      echo "$(date): RAM crossed 90%: $ram%" >> $log_file
      ram_flag=1
    fi
  else
    if [ $ram_flag -eq 1 ]; then
      echo "$(date): RAM went below 90%" >> $log_file
      ram_flag=0
    fi
  fi

  # Check Disk usage
  if [ $disk -ge $disk_threshold ]; then
    if [ $disk_flag -eq 0 ]; then
      echo "$(date): Disk crossed 90%: $disk%" >> $log_file
      disk_flag=1
    fi
  else
    if [ $disk_flag -eq 1 ]; then
      echo "$(date): Disk went below 90%" >> $log_file
      disk_flag=0
    fi
  fi

  # Check response code internally
  if [ $response_int -ne $response_code ]; then
    if [ $response_int_flag -eq 0 ]; then
      echo "$(date): failed to reach the page via localhost" >> $log_file
      response_int_flag=1
    fi
  else
    if [ $response_int_flag -eq 1 ]; then
      echo "$(date): the page became reachable on localhost" >> $log_file
      response_int_flag=0
    fi
  fi

 # Check response code on public IP - optionally
#  if [ $response_ext -ne $response_code ]; then
#    if [ $response_ext_flag -eq 0 ]; then
#      echo "$(date): failed to reach the page via the public IP" >> $log_file
#      response_int_flag=1
#    fi
#  else
#    if [ $response_int_flag -eq 1 ]; then
#      echo "$(date): the page became reachable on the public IP " >> $log_file
#      response_int_flag=0
#    fi
#  fi

  sleep 1
done