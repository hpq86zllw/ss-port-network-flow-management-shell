#基于shell脚本的ss端口网络流量管理  
##运行要求  
只能在安装了iptables的linux系统上使用  
##各脚本作用  
env 环境变量  
init 初始化  
add-port [port] 添加监控端口  
check-network-flow 检查端口流量，如果流量超过设置值（储存在port.dat文件中）则屏蔽该端口  
clear-network-flow [port] 端口流量清零  
enable-port [port] 恢复被屏蔽的端口（恢复之前需要将端口的流量清零）  
##使用说明  
1.修改init，add-port，check-network-flow，clear-network-flow和enable-port中的SCRIPT_HOME变量为脚本主目录  
2.运行init在iptables中添加自定义链  
3.在port.dat中添加要监控的端口和最大流量值  
4.运行add-port [port]在iptables中添加要监控的端口  
5.使用crontab命令为check-network-flow添加定时任务  
##恢复被屏蔽的端口  
首先运行clear-network-flow [port]清空端口流量，然后运行enable-port [port]恢复被屏蔽的端口  
##port.dat文件格式  
监控端口 最大流量值（单位为bytes）  
例子  
8080 10240  
8081 2028  
