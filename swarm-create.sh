#!/bin/bash

NODE_COUNT=${NODE_COUNT:=5}
NODE_PREFIX=${NODE_PREFIX:=dock-node}
NODES=()
for i in $( seq 1 $NODE_COUNT );
do
    NODES+=($(printf "${NODE_PREFIX}-%03d " "$i"))
done
#NODES=(${NODE_PREFIX}-00{1..$NODE_COUNT})
NODES_LEN=${#NODES[@]}
LEADER_NODE="${NODES[0]}"
LEADER_COUNT=${LEADER_COUNT:=3}

#BOOT2DOCKER_ISO="${HOME}/iso/boot2docker.iso"
echo "Create ${NODES_LEN} node docker swarm"
echo ""
for (( index=0; index<${NODES_LEN}; index++ ));
do
  docker-machine status ${NODES[index]} &> /dev/null
  retVal=$?
  if [ $retVal -eq 1 ]; then
    echo "Create '${NODES[index]}' node"
    # docker-machine create --driver virtualbox \
    #                         --virtualbox-boot2docker-url ${BOOT2DOCKER_ISO} \
    #                          ${NODES[index]} &> /dev/null

    docker-machine create --driver virtualbox \
                          ${NODES[index]} &> /dev/null
  fi
done
echo ""
echo "Create swarm"

echo "Electing leader"
eval $(docker-machine env ${LEADER_NODE})

LEADER_IP=$(docker-machine inspect ${LEADER_NODE} | jq .Driver.IPAddress | tr -d '"')
echo "Leader name: '${LEADER_NODE}' ip: '${LEADER_IP}'"

echo ""
echo "Initializing swarm"
docker swarm init --advertise-addr ${LEADER_IP} &> /dev/null
JOIN_CMD=$(docker swarm join-token worker | grep token)
echo ""
for (( index=1; index<${NODES_LEN}; index++ ));
do
  docker-machine status ${NODES[index]} &> /dev/null
  retVal=$?
  if [ $retVal -eq 0 ]; then
    echo "Running '${JOIN_CMD}' against '${NODES[index]}'"
    eval $(docker-machine env ${NODES[index]})
    echo "Join '${NODES[index]}' node as worker"
    ${JOIN_CMD}  &> /dev/null
  fi
done

echo ""
echo "Promoting additional leaders"
eval $(docker-machine env ${LEADER_NODE})
for (( index=1; index<${NODES_LEN}; index++ ));
do
  docker-machine status ${NODES[index]} &> /dev/null
  retVal=$?
  if [ $retVal -eq 0 ]; then
    if [ $(($index + 1)) -le $LEADER_COUNT ]; then
      docker node promote ${NODES[index]}
    fi
  fi
done

echo ""
sleep 2s
docker node ls
