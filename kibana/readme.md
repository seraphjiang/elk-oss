# Getting Started

## Introduction

This is an example all in one dockerfile to run elasticsearch on 9200 and kibana on 5601. It is only for test and study purpose, not for production.

## Prerequisite

```
# download elasticsearch and kibana
curl --retry 8 -s -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.9.0-linux-x86_64.tar.gz
curl --retry 8 -s -L -O https://artifacts.elastic.co/downloads/kibana/kibana-oss-7.9.0-linux-x86_64.tar.gz

# download elasticsearch and kibana
```

## Build Images

```
docker build . --tag kbn
```

## Run Container

```
docker run --rm  -p 9200:9200 -p:5601:5601 --name test-kbn kbn
# --rm remove container after stop
# -p host port:container port in bridge network mode. Mac doesn't support host mode yet
# --name container name
```

## login to containers

```
docker exec -it test-kbn /bin/bash    
```

## others

```
# show all contains
docker ps -a

# show all Images
docker image ls -a

# show only container id
docker ps -a -q

# stop all containers
docker stop $(docker ps -q)

# remove all containers
docker rm $(docker ps -q) -f

# remove all images
docker rmi $(docker images -a -q) 

```