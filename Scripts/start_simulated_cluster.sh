scale=$1
servers_size=$2
worker_num=$3

sh ./Scripts/set_compiler_config.sh $servers_size $worker_num y
sh ./Scripts/set_executor_config.sh $servers_size 0 y

nohup sh ./Scripts/start_compiler.sh > ./Logs/compiler.log 2>&1 &

id=0
while (($id<$servers_size))
do
    nohup sh ./Scripts/start_executor.sh $scale $servers_size $id $((1234+$id)) $((11234+$id)) > ./Logs/executor_$id.log 2>&1 &
    ((id++))
done
