servers_size=$1
worker_num=$2
glogue=$3
is_simulated=$4

if [[ -z "$glogue" ]]
then
    glogue="glogue"
fi


if [ "$is_simulated" == "y" ]
then
    local_ips=$(hostname -I)
    IFS=' ' read -ra ip_array <<< "$local_ips"
    local_ip=${ip_array[0]}

    worker_num_config="pegasus.worker.num: ${worker_num}";

    timeout_config="pegasus.timeout: 240000"

    batch_size_config="pegasus.batch.size: 1024";

    output_capacity_config="pegasus.output.capacity: 16";

    hosts_config="pegasus.hosts: $local_ip:1234";

    count=1;
    while (($count<$servers_size))
    do
        host=",$local_ip:$((1234+$count))"
        hosts_config+=$host
        (( count++ ))
    done

    server_num_config="pegasus.server.num: $servers_size"

    graph_schema_config="graph.schema: /opt/resources/Schemas/ldbc_schema.json"

    catalog_path_config="catalog.path: /opt/resources/GLogues/$glogue"

    properties="$worker_num_config\n$timeout_config\n$batch_size_config\n$output_capacity_config\n$hosts_config\n$server_num_config\n$graph_schema_config\n$catalog_path_config"

    echo -e $properties > ./Config/Compiler_Config/ir.compiler.properties
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

    ips=()
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ server[0-9][0-9]*_ip:.+$ ]]
        then
            IFS=":" read -ra ip_split <<< $line
            ips+=("${ip_split[1]//[[:blank:]]/}")
        fi
    done < ./Config/IP_Config.txt

    worker_num_config="pegasus.worker.num: ${worker_num}";

    timeout_config="pegasus.timeout: 240000"

    batch_size_config="pegasus.batch.size: 1024";

    output_capacity_config="pegasus.output.capacity: 16";

    hosts_config="pegasus.hosts: ";
    server_id=0
    while (($server_id<$servers_size))
    do
        host="${ips[$server_id]}:$rpc_port"
        hosts_config+=$host
        if (($server_id<$(($servers_size-1))))
        then
            hosts_config+=","
        fi
        ((server_id++))
    done

    server_num_config="pegasus.server.num: $servers_size"

    graph_schema_config="graph.schema: /opt/resources/Schemas/ldbc_schema.json"

    catalog_path_config="catalog.path: /opt/resources/GLogues/$glogue"

    properties="$worker_num_config\n$timeout_config\n$batch_size_config\n$output_capacity_config\n$hosts_config\n$server_num_config\n$graph_schema_config\n$catalog_path_config"

    echo -e $properties > ./Config/Compiler_Config/ir.compiler.properties
fi
