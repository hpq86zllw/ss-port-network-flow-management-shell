source ~/.bash_profile
source $SS_SCRIPT_HOME/env

port=$1

$SS_SCRIPT_HOME/clear-network-flow.sh $port
$SS_SCRIPT_HOME/enable-port.sh $port
