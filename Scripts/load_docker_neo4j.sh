mkdir -p ./Images
cd ./Images
rm -f neo4j.tar
echo "Downloading the neo4j image from oss..."
if curl -o neo4j.tar "http://graphscope.oss-cn-beijing.aliyuncs.com/atc23%2Fglogs%2FImages%2Fneo4j.tar"; then
    echo "Loading the neo4j image..."
    docker load --input neo4j.tar
else
    echo "Fail to download the neo4j image!"
fi