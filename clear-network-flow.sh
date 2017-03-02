source ~/.bash_profile
source $SS_SCRIPT_HOME/env

port=$1
date=`date +%Y%m%d%H%M%S`

#generate port line number file
iptables -nL $OUTPUT_CHAIN_NAME --line-number | awk '$2=="ACCEPT" {print $1,$8}' | sed 's/spt://g' | awk '$2=="'$port'" {print $1}' > $PORT_LINE_NUMBER_FILE

if [ ! -s $PORT_LINE_NUMBER_FILE ]
then
    echo "Can not find port:$port record"
    rm -f $PORT_LINE_NUMBER_FILE
    exit 0
fi

echo "Clear port:$port network flow"
while read line
do

    lineNum=($line)
    iptables -Z $OUTPUT_CHAIN_NAME $lineNum

done < $PORT_LINE_NUMBER_FILE

rm -f $PORT_LINE_NUMBER_FILE
