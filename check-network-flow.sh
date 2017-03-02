source $SS_SCRIPT_HOME/env

date=`date +%Y%m%d%H%M%S`
TMP_HOME="$SS_SCRIPT_HOME/tmp"
networkFlowTempFile="$TMP_HOME/network-flow-$date"
disabledPortTempFile="$TMP_HOME/disabled-port-$date"
portDataFile="$SS_SCRIPT_HOME/port.dat"
portNetworkFlowDataFile="$SS_SCRIPT_HOME/port-network-flow.dat"
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
    $IPTABLES -I $INPUT_CHAIN_NAME -p udp --dport $port -j DROP
    $IPTABLES -I $INPUT_CHAIN_NAME -p tcp --dport $port -j DROP
    return 0

}

#generate network flow file
$IPTABLES -nvxL $OUTPUT_CHAIN_NAME | awk '$3=="ACCEPT" {print $2,$11}' | sed 's/spt://g' > $networkFlowTempFile
#generate disabled port file
$IPTABLES -nvxL $INPUT_CHAIN_NAME | awk '$3=="DROP" {print $11}' | sed 's/dpt://g' > $disabledPortTempFile

rm $portNetworkFlowDataFile
echo -n "" > $portNetworkFlowDataFile
while read line
do

    portData=($line)
    port=${portData[0]}
    maxNetworkFlow=${portData[1]}

    networkFlow=`getNetworkFlow $networkFlowTempFile $port`
#    echo "port:$port,maxNetworkFlow:$maxNetworkFlow,currentNetworkFlow:$networkFlow"
	echo -e "$port $maxNetworkFlow $networkFlow" >> $portNetworkFlowDataFile
    if [ $networkFlow -ge $maxNetworkFlow ]
    then
        disablePort $disabledPortTempFile $port
        if [ $? -eq 0 ]
        then
            hasNewDisabledPort=1
        fi
    fi

done < $portDataFile

if [ $hasNewDisabledPort -eq 1 ]
then
    $SERVICE iptables save
fi
rm $networkFlowTempFile
rm $disabledPortTempFile
