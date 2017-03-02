source $SS_SCRIPT_HOME/env

port=$1

recordNum=`$IPTABLES -nL $OUTPUT_CHAIN_NAME | awk '$1=="ACCEPT" {print $7}' | sed 's/spt://g' | awk '$1=="'$port'" {print $1}' | wc -l`
if [ $recordNum -ne 0 ]
then
    echo "port:$port is already added"
    exit 0
fi

echo "Add port:$port"
$IPTABLES -A $OUTPUT_CHAIN_NAME -p tcp --sport $port -j ACCEPT
$IPTABLES -A $OUTPUT_CHAIN_NAME -p udp --sport $port -j ACCEPT
