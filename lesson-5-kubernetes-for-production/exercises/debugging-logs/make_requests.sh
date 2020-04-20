#!/bin/bash

for i in {1..4}
do
  sleep 1
  curl --request GET localhost:8080/users/justin  > /dev/null 2>&1 &
done 
