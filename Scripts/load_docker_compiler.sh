version=$1

mkdir -p ./Images
cd ./Images
rm -f glogs-compiler${version}.tar
echo "Downloading the compiler image from oss..."
if curl -o glogs-compiler${version}.tar -L "http://graphscope.oss-cn-beijing.aliyuncs.com/atc23%2Fglogs%2FImages%2Fglogs-compiler${version}.tar"; then
    echo "Loading the compiler image..."
    docker load --input glogs-compiler${version}.tar
else
    echo "Fail to download compiler image!"
fi
