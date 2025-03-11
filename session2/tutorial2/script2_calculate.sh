#!/bin/bash

read -p "Number of simulations to perform (default of 5): " steps

steps=${steps:-5}

echo "Starting a demo calculation with $steps steps"
echo ""

for ((i=1; i<=$steps; i++))
do
  echo "Progress: Step $i completed"
  sleep 3
done
