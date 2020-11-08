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

## Deploy to AWS Fargate

### Push image to ECR

1. Retrieve an authentication token and authenticate your Docker client to your registry.

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 544277935543.dkr.ecr.us-east-1.amazonaws.com
```

2. Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here . You can skip this step if your image is already built:

```
docker build -t kbn .
```

3. After the build completes, tag your image so you can push the image to this repository:

```
docker tag kbn:latest 544277935543.dkr.ecr.us-east-1.amazonaws.com/kbn:latest
```

4. Run the following command to push this image to your newly created AWS repository:

```
docker push 544277935543.dkr.ecr.us-east-1.amazonaws.com/kbn:latest
```

### Deploy to Amazon ECR 

https://github.com/abaird986/aws-modern-application-workshop/blob/master/module-2/README.md

1. Create An AWS Fargate Cluster

```
aws ecs create-cluster \
--cluster-name kbn-test-cluster \
--region us-east-1
```
2. Create log group

```
aws logs create-log-group --log-group-name /ecs/kbn-1 --region us-east-1
```

3. Register An ECS Task Definitio

```
aws ecs register-task-definition \
--cli-input-json file://aws-cli/fargate-kibana-task.json \
--region us-east-1
```

4. Create A Network Load Balancer

```
aws elbv2 create-load-balancer \
--name kbn-alb-4 \
--scheme internet-facing \
--type application \
--security-groups sg-0f9504c25e0bf6ac4 \
--subnets subnet-0818f4db13620f3e9 subnet-0da58f6fbed05ea03 \
--region us-east-1
```

5. Create A Load Balancer Target Group

```
aws elbv2 create-target-group \
--name kbn-alb-tg-1-4 \
--port 5601 \
--protocol HTTP \
--target-type ip \
--vpc-id vpc-070d63a72d1cf59ba \
--health-check-interval-seconds 10 \
--health-check-path /api/status \
--health-check-protocol HTTP \
--healthy-threshold-count 3 \
--unhealthy-threshold-count 3 \
--region us-east-1
```

6. Create A Load Balancer Listener

```
aws elbv2 create-listener \
--default-actions TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:544277935543:targetgroup/kbn-alb-tg-1-4/d258dd07e715879b,Type=forward \
--load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:544277935543:loadbalancer/app/kbn-alb-4/972555efb5004483 \
--port 80 \
--protocol HTTP \
--region us-east-1
```

7. Create A Service Linked Role For ECS

```
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
```

8. Create The Service

```
aws ecs create-service \
--cli-input-json file://aws-cli/fargate-kibana-service-definition.json \
--region us-east-1
```

9. Test

```
http://kbn-alb-4-abc123456.elb.us-east-1.amazonaws.com/
```