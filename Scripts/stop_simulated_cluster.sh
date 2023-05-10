executors=$(docker ps -a -q --filter ancestor=glogs-executor:v1.0 --format="{{.ID}}")
compilers=$(docker ps -a -q --filter ancestor=glogs-compiler:v1.0 --format="{{.ID}}")
docker stop $executors
docker stop $compilers
docker rm $executors
docker rm $compilers