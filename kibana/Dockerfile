################################################################################
# Build stage 0 `builder`:
# Extract artifact
# Set gid=0 and make group perms==owner perms
################################################################################

FROM ubuntu:18.04 as builder
RUN mkdir -p /app
COPY elasticsearch-oss-7.8.0-linux-x86_64.tar.gz /app/
COPY kibana-oss-7.8.0-linux-x86_64.tar.gz /app/
WORKDIR /app/
RUN tar xzvf elasticsearch-oss-7.8.0-linux-x86_64.tar.gz
RUN tar xzvf kibana-oss-7.8.0-linux-x86_64.tar.gz

################################################################################
# Build stage 1 
# Copy  from stage 0
# Add entrypoint
################################################################################
FROM ubuntu:18.04
RUN \
  apt-get update && \
  apt-get install -y curl vim net-tools supervisor

RUN groupadd --gid 1000 oss && \
    useradd --uid 1000 --gid 1000 --home-dir /app --no-create-home oss

COPY --from=builder --chown=1000:0 /app /app
COPY start.sh /app

RUN echo "\n" >> "/app/elasticsearch-7.8.0/config/elasticsearch.yml" && \
    echo "network.host: 0.0.0.0" >> "/app/elasticsearch-7.8.0/config/elasticsearch.yml" && \
    echo "discovery.type: single-node" >> "/app/elasticsearch-7.8.0/config/elasticsearch.yml" && \
    echo "server.host: 0.0.0.0" >> "/app/kibana-7.8.0-linux-x86_64/config/kibana.yml"

RUN chmod g=u /etc/passwd
EXPOSE 9200 9300 5601

USER oss

CMD /app/start.sh