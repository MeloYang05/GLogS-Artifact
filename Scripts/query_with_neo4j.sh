#!/bin/bash

QUERY_NO=1

while getopts ":q:" opt
do
    case $opt in
        q)
        QUERY_NO=$OPTARG
        ;;
esac done

export NEO4J_ENV_VARS=${NEO4J_ENV_VARS:-}


docker run --interactive --tty --rm \
    --name neo4j_glogs \
    --publish=7474:7474 --publish=7687:7687 \
    --env apoc.import.file.enabled=true \
    --env NEO4J_dbms_memory_pagecache_size=4G \
    neo4j:4.4.9 \
    /bin/bash \
    /var/lib/neo4j/resources/query/query/benchmark_ldbc1.sh -q $QUERY_NO
