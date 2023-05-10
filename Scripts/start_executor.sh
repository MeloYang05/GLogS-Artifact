scale=$1
servers_size=$2
id=$3
rpc_port=$4
shuffle_port=$5

if [[ -z "$rpc_port" ]]
then
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ rpc_port:.+$ ]]
        then
            IFS=":" read -ra port_split <<< $line
            rpc_port=("${port_split[1]//[[:blank:]]/}")
        fi
    done < ./Config/Port_Config.txt
fi

if [[ -z "$shuffle_port" ]]
then
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ shuffle_port:.+$ ]]
        then
            IFS=":" read -ra port_split <<< $line
            shuffle_port=("${port_split[1]//[[:blank:]]/}")
        fi
    done < ./Config/Port_Config.txt
fi


docker run --mount type=bind,source=$PWD,target=/opt/resources\
                -p ${rpc_port}:${rpc_port}\
                -p ${shuffle_port}:${shuffle_port}\
                -e RUST_LOG=Info\
                -e DATA_PATH=/opt/resources/Graphs/scale_${scale}/bin_p${servers_size}/partition_${id}\
                glogs-executor:v1.0\
                /opt/GraphScope/interactive_engine/executor/ir/target/release/start_rpc_server --config /opt/resources/Config/Executor_Config/distributed_${servers_size}/server_${id}