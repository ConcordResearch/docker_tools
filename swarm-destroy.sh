#!/bin/bash
NODE_COUNT=${NODE_COUNT:=5}
NODE_PREFIX=${NODE_PREFIX:=dock-node}
NODES=()
for i in $( seq 1 $NODE_COUNT );
do
    NODES+=($(printf "${NODE_PREFIX}-%03d " "$i"))
done

#NODES=(${NODE_PREFIX}-00{1..${NODE_COUNT}
NODES_LEN=${#NODES[@]}

for (( index=0; index < NODES_LEN; index++ ));
do
  docker-machine status "${NODES[index]}" &> /dev/null
  retVal=$?
  if [ $retVal -eq 0 ]; then
    echo "Destroying '${NODES[index]}' node"
    docker-machine rm "${NODES[index]}" --force &> /dev/null
  fi
done
