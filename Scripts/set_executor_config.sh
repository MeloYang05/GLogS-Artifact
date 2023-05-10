servers_size=$1
id=$2
is_simulated=$3

if [ "$is_simulated" == "y" ]
then
    local_ips=$(hostname -I)
    IFS=' ' read -ra ip_array <<< "$local_ips"
    local_ip=${ip_array[0]}

    id=0
    while (($id<$servers_size))
    do
        mkdir -p "./Config/Executor_Config/distributed_${servers_size}/server_${id}"
        rpc_host_config="rpc_host = '0.0.0.0'"
        rpc_port_config="rpc_port = $((1234+$id))"
        rpc_config="$rpc_host_config\n$rpc_port_config"
        echo -e $rpc_config > ./Config/Executor_Config/distributed_${servers_size}/server_${id}/rpc_config.toml

        netork_config="[network]\nserver_id = $id\nservers_size = $servers_size"
        network_servers_config=""
        server_id=0
        while (($server_id<$servers_size))
        do
            network_servers_config+="[[network.servers]]\n"
            if (($id==$server_id))
            then
                network_servers_config+="hostname = '0.0.0.0'\n"
            else
                network_servers_config+="hostname = '$local_ip'\n"
            fi
            network_servers_config+="port = $((11234+$server_id))\n"
            ((server_id++))
        done
        server_config="$netork_config\n$network_servers_config"
        echo -e $server_config > ./Config/Executor_Config/distributed_${servers_size}/server_${id}/server_config.toml
        ((id++))
    done
else
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ compiler_port:.+$ ]]
        then
            IFS=":" read -ra port_split <<< $line
            compiler_port=("${port_split[1]//[[:blank:]]/}")
        fi
        if [[ "$line" =~ rpc_port:.+$ ]]
        then
            IFS=":" read -ra port_split <<< $line
            rpc_port=("${port_split[1]//[[:blank:]]/}")
        fi
        if [[ "$line" =~ shuffle_port:.+$ ]]
        then
            IFS=":" read -ra port_split <<< $line
            shuffle_port=("${port_split[1]//[[:blank:]]/}")
        fi
    done < ./Config/Port_Config.txt

    mkdir -p "./Config/Executor_Config/distributed_${servers_size}/server_${id}"
    rpc_host_config="rpc_host = '0.0.0.0'"
    rpc_port_config="rpc_port = $rpc_port"
    rpc_config="$rpc_host_config\n$rpc_port_config"
    echo -e $rpc_config > ./Config/Executor_Config/distributed_${servers_size}/server_${id}/rpc_config.toml

    ips=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ server[0-9][0-9]*_ip:.+$ ]]
        then
            IFS=":" read -ra ip_split <<< $line
            ips+=("${ip_split[1]//[[:blank:]]/}")
        fi
    done < ./Config/IP_Config.txt

    netork_config="[network]\nserver_id = $id\nservers_size = $servers_size"
    network_servers_config=""
    server_id=0
    while (($server_id<$servers_size))
    do
        network_servers_config+="[[network.servers]]\n"
        if (($id==$server_id))
        then
            network_servers_config+="hostname = '0.0.0.0'\n"
        else
            network_servers_config+="hostname = '${ips[$server_id]}'\n"
        fi
        network_servers_config+="port = $shuffle_port\n"
        ((server_id++))
    done
    server_config="$netork_config\n$network_servers_config"
    echo -e $server_config > ./Config/Executor_Config/distributed_${servers_size}/server_${id}/server_config.toml
fi

