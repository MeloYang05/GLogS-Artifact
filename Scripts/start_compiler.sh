while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ compiler_port:.+$ ]]
    then
        IFS=":" read -ra port_split <<< $line
        port=("${port_split[1]//[[:blank:]]/}")
    fi
done < ./Config/Port_Config.txt

docker run --mount type=bind,source=$PWD,target=/opt/resources\
                -p ${port}:8182\
                glogs-compiler:v1.0\
                bash -c "cp -f /opt/resources/Config/Compiler_Config/ir.compiler.properties /opt/GraphScope/interactive_engine/compiler/conf  && cd /opt/GraphScope/interactive_engine/compiler && make run"