source $SS_SCRIPT_HOME/env

port=$1
date=`date +%Y%m%d%H%M%S`
TMP_HOME="$SS_SCRIPT_HOME/tmp"
portLineNumberFile="$TMP_HOME/port-line-number-$date"

#generate port line number file
$IPTABLES -nL $OUTPUT_CHAIN_NAME --line-number | awk '$2=="ACCEPT" {print $1,$8}' | sed 's/spt://g' | awk '$2=="'$port'" {print $1}' > $portLineNumberFile

if [ ! -s $portLineNumberFile ]
then
    echo "Can not find port:$port record"
    rm $portLineNumberFile
    exit 0
fi

echo "Clear port:$port network flow"
while read line
do

    lineNum=($line)
    $IPTABLES -Z $OUTPUT_CHAIN_NAME $lineNum

done < $portLineNumberFile

rm $portLineNumberFile
