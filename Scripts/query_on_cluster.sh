id=$1
has_predicate=$2

while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ compiler_server_ip:.+$ ]]
    then
        IFS=":" read -ra ip_split <<< $line
        compiler_ip=("${ip_split[1]//[[:blank:]]/}")
    fi
done < ./Config/IP_Config.txt

while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ compiler_port:.+$ ]]
    then
        IFS=":" read -ra port_split <<< $line
        compiler_port=("${port_split[1]//[[:blank:]]/}")
    fi
done < ./Config/Port_Config.txt

cd ./Benchmark/gaia-benchmark-0.0.1-SNAPSHOT/
echo "endpoint=$compiler_ip:$compiler_port" > ./config/interactive-benchmark.properties
cat ./config/interactive-benchmark_empty.properties >> ./config/interactive-benchmark.properties

if [[ -z "$has_predicate" ]]
then
    has_predicate="n"
fi

if (($id<4))
then
    echo -e "\ncustom_constant_query_${id}.enable=true" >> ./config/interactive-benchmark.properties
else
    if [ "$has_predicate" == "y" ]
    then
        echo -e "\ncustom_query_${id}.enable=true" >> ./config/interactive-benchmark.properties
    else
        echo -e "\ncustom_constant_query_${id}.enable=true" >> ./config/interactive-benchmark.properties
    fi
fi


./scripts/benchmark.sh