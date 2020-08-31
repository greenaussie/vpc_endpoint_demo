#!/bin/bash

#
# UNSW IT STaR Domain > Faculty Subdomain > DevOps Team
#  _____
# |  ___|_/\__    Copyright UNSW 2020 All Rights Reserved
# | |_  \    /
# |  _| /_  _\    1. Do not redistribute without permission.
# |_|     \/      2. Do not remove this notice
#
#                 Extend this notice if required
#
# Created by Richard Green, richard.green@unsw.edu.au, 2020
#

set -e

if [ "$CONTAINER_ENGINE" != "podman" ]
then
  CONTAINER_ENGINE="docker"
fi

stage=$1
stackname=devops-show-and-tell-demo-vpc-endpoints

stackup="${CONTAINER_ENGINE} run --rm \
  -v `pwd`:/cwd:Z \
  -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN \
  -e AWS_DEFAULT_REGION -e AWS_REGION \
  realestate/stackup:latest"

command="$stackup ${stackname} up -t cfn/templates/010_resources.yml \
  --tags cfn/tags.yml"
# echo $command
eval $command