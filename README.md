# GLogS Artifact (USENIX ATC 2023)

This repository holds the artifact of the paper "GLogS: Interactive Graph Pattern Matching Query At Large Scale" published on USENIX ATC 2023. 

GLogS is a system designed for interactive graph pattern matching query at large scale, which allows users to interactively submit queries using a declarative language. The system will compile and compute optimal execution plans for the queries, and execute them on an existing distributed dataflow engine. You can find the source code of GLogS [here](https://github.com/shirly121/GraphScope/tree/ir_catalog_dev/interactive_engine). 

## 1. System Specification

### 1.1 Hardware Dependencies

As stated in the paper, we deployed a cluster for the evaluation, which consisted of one frontend server and up to 16 backend servers. Each server was configured with:

- 2 * 24-core 48-thread Intel(R) Xeon(R) Platinum 8163 CPUs at 2.50GHz
- 512GB RAM
- 2TB SSD

In addition, a 25Gbps network card was used to connect these servers. Such a high-spec cluster was necessary to handle the complexity of pattern matching queries at a large scale. We understand that reproducing a high-spec cluster like this can be challenging, which is why we have prepared relatively small datasets in this artifact by default. Furthermore, we have also included a script that allows you to quickly simulate a 'mini' cluster containing up to 8 backend servers locally, so that you can conveniently validate GLogS's performance. Detailed instructions on how to configure a GLogS cluster will be provided in the later section.

### 1.2 Environment

Most of the components of GLogS are written in Rust, except for the compiler for the graph declarative language, which is written in Java. To save time in setting up these components, we have prepared the execution environment in Docker images. You can deploy the environment by running the following command:

```bash
sh ./Scripts/load_docker_images.sh
```

Some basic tools, such as `curl`, are required. Additionally, since the benchmark tools for GLogS are written in Java, you should ensure that your machine has JDK >= 11 installed.

### 1.3 Datasets

Due to the size limit of the GitHub repository, we have uploaded the already partitioned graphs used in our experiments to the Object Storage Service of Alibaba Cloud. We have provided you with a script to quickly download and install the graph partitions onto your machine.

```bash
sh ./Scripts/load_graph.sh <scale> <partition_num>
```

For example, to download the scale-1 graph with 8 partitions, you can run the following command:

```bash
sh ./Scripts/load_graph.sh 1 8
```

This table shows our provided graphs with scales and partitions.

| Scale |   Partitions   |
| :---: | :------------: |
|   1   |   1, 2, 4, 8   |
|  100  | 1, 2, 4, 8, 16 |
|  300  |    4, 8, 16    |
| 1000  |       16       |

### 1.4 Artifact Directory

```
.
├── Benchmark        # benchmark tools
├── Catalogs         # catalogues(glogues) used in the experiments
├── Config           # configuration files
├── Graphs           # graphs used in the experiment
├── Images           # store docker images to provide execution environment
├── Logs             # logs of compiler and executors
├── Schemas          # schemas of graphs
└── Scripts          # scripts for conducting experiments or configuring the environment
```

## 2. Quick Evaluation

### 2.1 Experiment on single machine

We provide you with a convenient way to reproduce GLogS's performance on a single machine using non-partitioned graphs. Firstly, download the non-partitioned graph with the desired scale onto your machine by running:

```bash
sh ./Script/load_graph.sh <scale> 1
```

Then, you can verify GLogS's performance on a single machine with the following command:

```bash
sh ./Scripts/query_on_single_machine.sh <scale> <thread_num> <query_id> 
```

For example, if you want to test GLogS's performance on query p1 with 32 threads on a scale-1 graph, you can run:

```bash
sh ./Scripts/query_on_single_machine.sh 1 32 1
```

The output should look like:

```
############ Query Execution ############
start executing query...
Record { curr: None, columns: {0: OffGraph(Primitive(Long(41713)))} }
executing query time cost is 1000 ms
```

### 2.2 Experiment on a simulated cluster

Before simulating a GLogS cluster on your local machine, you should download the required graph by running:

```bash
sh ./Script/load_graph.sh <scale> <partition_num>
```

Next, you can quickly simulate a GLogS cluster consisting of one frontend server and several backend servers on your local machine by running the following command:

```bash
sh ./Scripts/start_simulated_cluster.sh <scale> <serser_num> <thread_num>
```

For example, the following command will start a cluster with 8 backend servers, with each server using 4 threads for computation, and each server will load 1 partition of the scale-1 graph separately:

```bash
sh ./Scripts/start_simulated_cluster.sh 1 8 4
```

After starting up the 'mini' cluster, the compiler server's log will be stored at `./Logs/compiler.log`, and the executor server logs will be stored at `./Logs/executor${i}.log` for each executor server. If every executor connects to each other successfully, you can use the `./Scripts/query_on_cluster.sh` script to submit queries to the cluster:

```bash
sh ./Scripts/query_on_cluster.sh <query_id>
```

For example, you can submit query p1 to the cluster by running the following command:

```bash
sh ./Scripts/query_on_cluster.sh 1
```

The output should look like:

```
Connect success.
Begin standard test...
QueryName[CUSTOM_QUERY_WITHOUT_PARAMETER_1], Parameter[{}], ResultCount[1], ExecuteTimeMS[1572]. Result: { 
result{object=41713 class=java.lang.Long} }
query count: 1; execute time(ms): 1940; qps: 0.51546395
```

Finally, you can use `./Scripts/stop_simulated_cluster.sh` to stop the cluster

```bash
sh ./Scripts/stop_simulated_cluster.sh
```

## 3. GLogS Cluster Configuration

A GLogS cluster consists of one frontend server and several backend servers. The frontend server compiles the submitted graph queries and delivers the task to the backend servers for execution. Each backend server stores one graph partition, and the number of graph partitions should be equal to the number of backend servers. For example, if the graph has four partitions, then the cluster should have exactly four backend servers: Backend server 0 stores graph partition 0, server 1 stores partition 1, server 2 stores partition 2, and server 3 stores partition 3.

Configuring a GLogS cluster mainly involves these steps:

1. Setting up IPs and ports for all servers
2. Configuring the frontend server
3. Configuring each backend server
4. Starting up the cluster
5. Submitting queries

Next, we will illustrate the step-by-step configuration of a GLogS cluster.

### 3.1 Set up IPs and Ports

Firstly, you should `git clone` the artifact repository to one machine in your cluster. The IP and port configurations are stored separately in `./Config/IP_Config.txt` and `./Config/Port_Config.txt`, respectively. 

The content of the IP configuration file should be as follows:

```
compiler_server_ip: <IP>
server0_ip: <IP>
server1_ip: <IP>
server2_ip: <IP>
server3_ip: <IP>
server4_ip: <IP>
server5_ip: <IP>
server6_ip: <IP>
server7_ip: <IP>
server8_ip: <IP>
server9_ip: <IP>
server10_ip: <IP>
server11_ip: <IP>
server12_ip: <IP>
server13_ip: <IP>
server14_ip: <IP>
server15_ip: <IP>
```

To configure the IPs in your cluster, you should replace the placeholder IPs with the actual IPs of your servers. The compiler server's IP is used for later query submission. If you are currently on the frontend server and decide to submit a query on the same server, you can set the compiler server's IP to "127.0.0.1". Otherwise, you should use the frontend server's IP in the cluster. If your cluster contains n backend servers, you should specify the IPs from server0 to server{n-1}. The number following the "server" keyword is the ID of the server, and it cannot be mixed up, as the backend server with ID i should store exactly graph partition i.

The content of the port configuration file should be as follows:

```
compiler_port: 31812
rpc_port: 1234
shuffle_port: 11234
```

The `compiler_port` specifies the port of the frontend server used for query submission. The `rpc_port` is the port of the backend servers used for receiving tasks from the frontend server through the RPC service. The `shuffle_port` is the port used among the backend servers for data shuffling during task execution. These ports have default values, so it is better to keep the default settings unless there are conflicts with your port configurations. After configuration, you should ensure that these ports are available and not already in use on all servers in the cluster.

After configuring the IPs and ports, we suggest that you use the `scp` command to send the current artifact folder to all servers of the cluster in order to maintain consistency in the IPs and ports configuration.

```bash
scp -r ./Artifact <server_hostname>:<Artifact Directory>
```

### 3.2 Configure the Frontend Server

Assuming you are already in the artifact directory, you should configure the execution environment of the compiler by running:

```bash
sh ./Scripts/load_docker_compiler.sh
```

Next, configure the compiler according to the IPs and ports files by running:

```bash
sh ./Scripts/set_compiler_config.sh <server_num> <thread_num>
```

where `<server_num>` represents the number of backend servers, and `<thread_num>` indicates the number of threads participating in the computation of each backend server."

### 3.3 Configure each Backend Server

On each backend server, the first step is to configure the execution environment of the executor by running:

```bash
sh ./Scripts/load_docker_executor.sh
```

Next, load the specific graph partition onto the server. As mentioned earlier, the number of backend servers should be equal to the number of graph partitions, and the backend server with ID `i` should store exactly graph partition `i`. Therefore, assuming that `scale` is the required graph scale, `server_num` is the number of backend servers, and `<id>` is the ID of the current backend server, you can load the graph partition by running:

```bash
sh ./Scripts/load_graph_partition.sh <scale> <server_num> <id>
```

Finally, configure the executor according to the IPs and ports files by running:

```bash
sh ./Scripts/set_executor_config.sh
```

### 3.4 Start up the cluster

After configuring the frontend server and all the backend servers, it is time to start up the cluster.

#### 3.4.1 Start up Executors on Backend Servers

We suggest starting up the executors on the backend servers in ascending order of their IDs. On each backend server, you can start up the executor by simply running:

```bash
sh ./Scripts/start_executor.sh <scale> <server_num> <id>
```

where `<scale>` is the graph scale, `<server_num>` is the number of backend servers, and `<id>` is the ID of the current backend server.

During the initialization of executor, it may takes several minutes to load the graph depends on the graph scale. Before the graph has been loaded, submitting queries to the cluster is not allowed.

#### 3.4.2 Start up compiler on Frontend Server

You can start up the compiler on the frontend server by running:

```bash
sh ./Scripts/start_compiler.sh
```

### 3.4 Submit Queries

After the compiler and all the executors are started up, you can submit queries to the GLogS cluster from any machine within the subnet, as long as the IPs and ports are properly configured in the two config files. To submit a query to the GLogS cluster, run:

```bash
sh ./Scripts/query_on_cluster.sh <query_id>
```

For example, to submit query p1 to the cluster, run the following command:

```bash
sh ./Scripts/query_on_cluster.sh 1
```

## 4 Reproduce Experiment Results

### 4.1 Compare GLogS with Neo4j

In the paper, we compared GLogS with Neo4j on a single machine using the scale-1 graph to allow Neo4j to process all queries in a reasonable time. To reproduce the experiment results, follow these steps:

First, load the Docker images of GLogS and Neo4j by running the following commands:

```bash
# Load the image of glogs executor
sh ./Scripts/load_docker_executor.sh
# Load the image of neo4j
sh ./Scripts/load_docker_neo4j.sh
```

Next, download the non-partitioned scale-1 graph by running:

```bash
# The first parameter means the scale of the graph is 1
# The second parameter means the graph only has 1 partition(non-paritioned)
sh ./Scripts/load_graph.sh 1 1
```

In the experiment, we used ten queries to verify the performance of GLogS and Neo4j. To validate the GLogS query performance for a specific pattern using the required number of threads (1- and 32-thread performance are reported in the paper), use the following commands:

```bash
# The first parameter is the id of the qeury for testing, ranging from 1 to 10
# The second parameter is the number of threads for processing the query parallelly
sh ./Scripts/query_on_single_machine.sh <query_id> <thread_num>
```

To validate our reported Neo4j performance, run:

```bash
# The first parameter is the id of the qeury for testing, ranging from 1 to 10
sh ./Scripts/query_with_neo4j.sh -q <query_id>
```

### 4.2 Compare GLogS with TigerGraph

In the paper, we compared GLogS with TigerGraph on a cluster containing 16 machines, using a scale-300 graph. For GLogS, each executor of the backend server is allowed to use up to 32 threads, while there's no parallel limitation for TigerGraph.

To validate GLogS's performance, first follow the instructions from Section 3 to build a cluster of 16 servers * 32 threads and load the scale-300 graph with 16 partitions. After the cluster is successfully started, run the following commands to submit queries to the cluster to validate our reported GLogS performance.

```bash
# The first parameter is the id of the qeury for testing, ranging from 1 to 10
sh ./Scripts/query_on_cluster.sh 1
```

### 4.3 Scalability of GLogS

In the paper, we illustrated GLogS's scalability by reporting its performance under different configurations of server number, thread number, and graph scale. To reproduce GLogS's performance under a specific configuration (server number, thread number, and graph scale), first start up a cluster configured by these instructions following the instructions in Section 3. Next, use the `query_on_cluster.sh` script to submit queries to the cluster and validate GLogS's performance.

```bash
# The first parameter is the id of the qeury for testing, ranging from 1 to 10
sh ./Scripts/query_on_cluster.sh 1
```

