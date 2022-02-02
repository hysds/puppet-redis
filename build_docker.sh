#!/bin/bash
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <tag> <github org> <github repo branch> <hysds release>"
  echo "e.g.: $0 20170620 hysds master v4.0.1-beta.7"
  echo "e.g.: $0 latest pymonger develop develop"
  exit 1
fi
TAG=$1
ORG=$2
BRANCH=$3
HYSDS_RELEASE=$4


# enable docker buildkit to allow build secrets
export DOCKER_BUILDKIT=1


# set oauth token to bypass github API rate limits
OAUTH_CFG="$HOME/.git_oauth_token"
if [ ! -e "$OAUTH_CFG" ]; then
  touch $OAUTH_CFG # create empty creds file for unauthenticated builds
fi


# build
docker build --progress=plain --rm --force-rm \
  -t hysds/redis:${TAG} -f docker/Dockerfile --build-arg HYSDS_RELEASE=${HYSDS_RELEASE} \
  --build-arg TAG=${TAG} --build-arg ORG=${ORG} --build-arg BRANCH=${BRANCH} \
  --secret id=git_oauth_token,src=$OAUTH_CFG . || exit 1
docker system prune -f || :
