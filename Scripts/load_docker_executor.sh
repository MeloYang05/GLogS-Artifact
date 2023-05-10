mkdir -p ./Images
cd ./Images
rm -f glogs-executor.tar
echo "Downloading the executor image from oss..."
if curl -o glogs-executor.tar "http://graphscope.oss-cn-beijing.aliyuncs.com/atc23%2Fglogs%2FImages%2Fglogs-executor.tar"; then
    echo "Loading the compiler image..."
    docker load --input glogs-executor.tar
else
    echo "Fail to download the executor image!"
fi