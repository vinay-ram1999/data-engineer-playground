#!/usr/bin/env bash
set -euo pipefail

# Maven Central Solr endpoint
SEARCH_URL="https://search.maven.org/solrsearch/select"

jars=(
  aws-java-sdk-bundle-1.12.365.jar
  hadoop-aws-3.3.4.jar
  nessie-spark-extensions-3.5_2.12-0.83.1.jar
  unitycatalog-spark_2.12-0.2.1.jar
  unitycatalog-client-0.3.0.jar
  slf4j-simple-2.0.7.jar
  bundle-2.29.52.jar
  iceberg-spark-runtime-3.5_2.12-1.8.1.jar
  delta-spark_2.12-3.3.1.jar
  slf4j-api-2.0.7.jar
  wildfly-openssl-1.0.7.Final.jar
)

OUTPUT_DIR="./data/jars"
mkdir -p "$OUTPUT_DIR"

for jar in "${jars[@]}"; do
  dest="$OUTPUT_DIR/$jar"

  # Skip if already downloaded
  if [[ -f "$dest" ]]; then
    echo "Skipping $jar: already exists at $dest"
    continue
  fi

  base="${jar%.jar}"
  # Split at the last dash before a digit
  if [[ "$base" =~ ^(.+)-([0-9].+)$ ]]; then
    artifact="${BASH_REMATCH[1]}"
    version="${BASH_REMATCH[2]}"
  else
    echo "Skipping $jar: cannot parse artifact/version" >&2
    continue
  fi

  # Query for groupId
  resp=$(curl -sG "$SEARCH_URL" \
    --data-urlencode "q=a:\"$artifact\" AND v:\"$version\"" \
    --data "rows=1&wt=json")

  group=$(echo "$resp" | jq -r '.response.docs[0].g // empty')
  if [[ -z "$group" ]]; then
    echo "No metadata for $artifact:$version" >&2
    continue
  fi

  # Build and fetch
  group_path=${group//./\/}
  url="https://repo1.maven.org/maven2/$group_path/$artifact/$version/$jar"
  echo "→ Downloading $jar from $url"
  curl -fSL "$url" -o "$dest"
done

echo "Done."
