#!/bin/bash
IFS='--'
lines=$(ifconfig |grep -A 1 "eth")

echo "***********************************************************************"
for line in $lines; do

  name=""
  ip=""
  sepa=$'\t'
  sepb=$'\t\t'

  regex='(eth[0-9]+)'
  if [[ "$line" =~ $regex ]]; then

    name=${BASH_REMATCH[1]}

  fi
  
  regex='addr:([0-9]+(\.[0-9]+)+)'
  if [[ "$line" =~ $regex ]]; then

    ip=${BASH_REMATCH[1]}

  fi

  if [ ${#name} -gt 0 ]; then
    echo "*$sepa$name$sepb$ip"
  fi
    
done
echo "***********************************************************************"

exit 1
