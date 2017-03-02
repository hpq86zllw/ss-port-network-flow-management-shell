source ~/.bash_profile
source $SS_SCRIPT_HOME/env

date=`date +%Y%m%d%H%M%S`
hasNewDisabledPort=0

getNetworkFlow(){

    networkFlowFile=$1
    port=$2

    awk 'BEGIN{totalBytes=0}{if($2=="'$port'")totalBytes+=$1}END{print totalBytes}' $networkFlowFile

}

disablePort(){

    disabledPortFile=$1
    port=$2
    isDisabled=0

    while read line
    do
        disabledPort=$line
        if [ $port -eq $disabledPort ]
        then
            isDisabled=1
            break
        fi
    done < $disabledPortFile

    if [ $isDisabled -eq 1 ]
    then
        return 1
    fi
    echo "Disable port:$port"
    iptables -I $INPUT_CHAIN_NAME -p udp --dport $port -j DROP
    iptables -I $INPUT_CHAIN_NAME -p tcp --dport $port -j DROP
    return 0

}

#generate network flow file
iptables -nvxL $OUTPUT_CHAIN_NAME | awk '$3=="ACCEPT" {print $2,$11}' | sed 's/spt://g' > $NETWORK_FLOW_TEMP_FILE
#generate disabled port file
iptables -nvxL $INPUT_CHAIN_NAME | awk '$3=="DROP" {print $11}' | sed 's/dpt://g' > $DISABLED_PORT_TEMP_FILE

rm -f $PORT_NETWORK_FLOW_DATA_FILE
echo -n "" > $PORT_NETWORK_FLOW_DATA_FILE
while read line
do

    portData=($line)
    port=${portData[0]}
    maxNetworkFlow=${portData[1]}

    networkFlow=`getNetworkFlow $NETWORK_FLOW_TEMP_FILE $port`
#    echo "port:$port,maxNetworkFlow:$maxNetworkFlow,currentNetworkFlow:$networkFlow"
	echo "$port $maxNetworkFlow $networkFlow" >> $PORT_NETWORK_FLOW_DATA_FILE
    if [ $networkFlow -ge $maxNetworkFlow ]
    then
        disablePort $DISABLED_PORT_TEMP_FILE $port
        if [ $? -eq 0 ]
        then
            hasNewDisabledPort=1
        fi
    fi

done < $PORT_DATA_FILE

if [ $hasNewDisabledPort -eq 1 ]
then
    service iptables save
fi
rm -f $NETWORK_FLOW_TEMP_FILE
rm -f $DISABLED_PORT_TEMP_FILE
