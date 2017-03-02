source $SS_SCRIPT_HOME/env

portDataFile="$SS_SCRIPT_HOME/port.dat"

$IPTABLES -N $INPUT_CHAIN_NAME
$IPTABLES -A INPUT -j $INPUT_CHAIN_NAME
$IPTABLES -N $OUTPUT_CHAIN_NAME
$IPTABLES -A OUTPUT -j $OUTPUT_CHAIN_NAME
$SERVICE iptables save

while read line
do

    portData=($line)
    port=${portData[0]}

    $SS_SCRIPT_HOME/add-port.sh $port

done < $portDataFile