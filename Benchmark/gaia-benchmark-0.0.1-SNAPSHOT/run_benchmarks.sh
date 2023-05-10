scale=100
server_nums="16 8 4 2 1"
worker_nums="32"

for server_num in ${server_nums}
do
  for worker_num in ${worker_nums}
  do
    ./run_benchmark.sh ${scale} ${server_num} ${worker_num}
    done
  done