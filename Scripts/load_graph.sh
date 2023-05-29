scale=$1
partition_num=$2
id=0
while (($id<$partition_num))
do
    bash ./Scripts/load_graph_partition.sh $scale $partition_num $id
    ((id++))
done