scale=$1
server_num=$2
worker_num=$3

echo "start test scale${scale} with ${server_num}servers and ${worker_num} workers"
ssh GraphK8sMaster "kubectl apply -f /home/admin/yufan/docker_files/gaia-cluster-${scale}-${server_num}-${worker_num}.yaml"
sleep 600
./scripts/benchmark.sh
ssh GraphK8sMaster "kubectl delete -f /home/admin/yufan/docker_files/gaia-cluster-${scale}-${server_num}-${worker_num}.yaml"