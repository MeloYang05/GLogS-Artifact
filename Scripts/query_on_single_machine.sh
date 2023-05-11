scale=$1
worker_num=$2
id=$3


docker run -it --mount type=bind,source=$PWD,target=/opt/resources\
                -e CATALOG_PATH=/opt/resources/Catalogs/catalog\
                -e SCHEMA_PATH=/opt/resources/Schemas/ldbc_schema.json\
                -e DATA_PATH=/opt/resources/Graphs/scale_${scale}/bin_p1/partition_0\
                -e PATTERN_PATH=/opt/resources/Benchmark/gaia-benchmark-0.0.1-SNAPSHOT/Patterns/p${id}.csv\
                glogs-executor:v1.0\
                /opt/GraphScope/interactive_engine/executor/ir/target/release/pattern_match  -w $worker_num -s hybrid