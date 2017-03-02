source $SS_SCRIPT_HOME/env

portDataFile="$SS_SCRIPT_HOME/port.dat"

iptables -N $INPUT_CHAIN_NAME
iptables -A INPUT -j $INPUT_CHAIN_NAME
iptables -N $OUTPUT_CHAIN_NAME
iptables -A OUTPUT -j $OUTPUT_CHAIN_NAME
service iptables save

while read line
do

    portData=($line)
    port=${portData[0]}

    $SS_SCRIPT_HOME/add-port.sh $port

done < $portDataFile