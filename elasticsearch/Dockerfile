# https://github.com/elastic/elasticsearch-docker
FROM docker.elastic.co/elasticsearch/elasticsearch:5.5.0

# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu

COPY ./entrypoint.sh /
COPY ./set_default_shards_and_replicas.sh /

USER root
ENTRYPOINT ["/entrypoint.sh"]
