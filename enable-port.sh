source $SS_SCRIPT_HOME/env

port=$1

recordNum=`iptables -nL $INPUT_CHAIN_NAME --line-number | awk '$2=="DROP" {print $1,$8}' | sed 's/dpt://g' | awk '$2=="'$port'" {print $1}' | wc -l`
if [ $recordNum -eq 0 ]
then
    echo "Can not find port:$port record"
    exit 0
fi

echo "Enable port:$port"
for ((i=1;i<=recordNum;i++))
do
    lineNumber=`iptables -nL $INPUT_CHAIN_NAME --line-number | awk '$2=="DROP" {print $1,$8}' | sed 's/dpt://g' | awk '$2=="'$port'" {print $1}' | awk 'NR==1 {print $1}'`
    iptables -D $INPUT_CHAIN_NAME $lineNumber
done

service iptables save
