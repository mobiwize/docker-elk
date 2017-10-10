#!/bin/bash

if [[ -z "${DEFAULT_NUMBER_OF_SHARDS// }" ]]; then
  echo "ERROR: DEFAULT_NUMBER_OF_SHARDS is not defined"
  exit 1
fi

if [[ -z "${DEFAULT_NUMBER_OF_REPLICAS// }" ]]; then
  echo "ERROR: DEFAULT_NUMBER_OF_REPLICAS is not defined"
  exit 1
fi

if [[ -z "${ELASTIC_INDEX_PREFIX// }" ]]; then
  echo "ERROR: ELASTIC_INDEX_PREFIX is not defined"
  exit 1
fi

echo "Setting the default number of shards to be [$DEFAULT_NUMBER_OF_SHARDS] and default number of replicas to be [$DEFAULT_NUMBER_OF_REPLICAS]"
echo "Also changing the template to be [$ELASTIC_INDEX_PREFIX-*]"

res="{}"
while [ $res == "{}" ]; do
  sleep 2
  res=`curl localhost:9200/_template/logstash`
done

curl http://localhost:9200/_template/logstash?pretty > template.old.json

# Delete the uneeded lines
sed -e '2d;3d;$d' template.old.json > template.new.json

if ! grep -q number_of_shards template.new.json; then
  sed -i "s/\"index\" \: {/\"index\" \: {\n\"number_of_shards\" \: \"$DEFAULT_NUMBER_OF_SHARDS\",/g" template.new.json
else
  sed -i "s/\"number_of_shards\" \: \"[0-9][0-9]*\"/\"number_of_shards\" \: \"$DEFAULT_NUMBER_OF_SHARDS\"/g" template.new.json
fi

if ! grep -q number_of_replicas template.new.json; then
  sed -i "s/\"index\" \: {/\"index\" \: {\n\"number_of_replicas\" \: \"$DEFAULT_NUMBER_OF_REPLICAS\",/g" template.new.json
else
  sed -i "s/\"number_of_replicas\" \: \"[0-9][0-9]*\"/\"number_of_replicas\" \: \"$DEFAULT_NUMBER_OF_REPLICAS\"/g" template.new.json
fi

sed -i "s/\"template\" \: \"[a-z]*-/\"template\" \: \"$ELASTIC_INDEX_PREFIX-/g" template.new.json

curl -XPUT 'http://localhost:9200/_template/logstash' -d @template.new.json --header "Content-Type: application/json"

rm template.old.json
rm template.new.json
