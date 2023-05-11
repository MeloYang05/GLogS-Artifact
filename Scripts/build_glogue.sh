depth=1

docker run -it --mount type=bind,source=$PWD,target=/opt/resources\
                -e SCHEMA_PATH=/opt/resources/Schemas/ldbc_schema.json\
                -e SAMPLE_PATH=/opt/resources/Graphs/scale_1/bin_p1/partition_0\
                glogs-executor:v1.0\
                /opt/GraphScope/interactive_engine/executor/ir/target/release/build_catalog  -m from_meta -p /opt/resources/Catalogs/catalog_depth_$depth -s /opt/resources/Config/Catalog_Config/ldbc_rate_01.json -l 10000 -t 32 -d $depth