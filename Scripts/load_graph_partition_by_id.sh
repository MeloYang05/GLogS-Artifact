id=$1
partition_nums=()
for scale in 1 30 100 300 1000
do
    if (($scale==1))
    then
        partition_nums=(1 2 4 8)
    elif (($scale==30))
    then
        partition_nums=(1 16)
    elif (($scale==100))
    then
        partition_nums=(1 2 4 8 16)
    elif (($scale==300))
    then
        partition_nums=(4 8 16)
    elif (($scale==1000))
    then
        partition_nums=(16)
    fi

    for partition_num in ${partition_nums[@]}
    do
        if (($id<$partition_num))
        then
            bash ./Scripts/load_graph_partition.sh $scale $partition_num $id
        fi
    done
done