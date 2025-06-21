#!/bin/bash

THIS_SCRIPT=$(readlink -f $0)
THIS_DIR=$(dirname $THIS_SCRIPT)
THIS_PROJECT=$(basename $THIS_DIR)

SUDO=sudo

if [ `id -u` -eq 0 ]
then
  SUDO=""
fi

if [ ! -x /usr/local/bin/ufw-docker ]
then
  echo "Error: ufw-docker not installed"
  exit 1
fi

CONTAINERS=$(docker container ls --format='{{ .Names }}')

for CONTAINER in $CONTAINERS
do

  PROJECT=$(docker inspect --format='{{index .Config.Labels "com.docker.compose.project"}}' $CONTAINER)

  if [ "${PROJECT}" != "${THIS_PROJECT}" ]
  then
    continue
  fi

  PORTS=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{(index $conf 0).HostPort}}:{{$p}} {{end}}' $CONTAINER)

  for PORT in $PORTS
  do
    EXTERNAL=$(echo $PORT | awk -F: '/:/ { print $1; }')
    PROTO=$(echo $PORT | awk -F/ '/\// { print $2; }')
    if [ ! -z ${PROTO:+z} ]
    then
      EXTERNAL="${EXTERNAL}/${PROTO}"
    fi
    echo -n "Opening port $PORT for $CONTAINER... "
    $SUDO ufw-docker allow $CONTAINER $EXTERNAL &> /dev/null
    if [ $? -eq 0 ]
    then
      echo "Done"
    else
      echo "Error: opening port ${PORT} for ${CONTAINER}"
    fi
  done

  $SUDO ufw-docker list ${CONTAINER}

done

