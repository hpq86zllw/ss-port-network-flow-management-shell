#基于shell脚本的ss端口网络流量管理  
##运行要求  
只能在安装了iptables的linux系统上使用  
##各脚本作用  
env 公共变量  
init.sh 初始化  
add-port.sh [port] 添加监控端口  
check-network-flow.sh 检查端口流量，如果流量超过设置值（储存在port.dat文件中）则屏蔽该端口  
clear-network-flow.sh [port] 端口流量清零  
enable-port.sh [port] 恢复被屏蔽的端口（恢复之前需要将端口的流量清零）  
resume-port.sh [port] 端口流量清零并恢复被屏蔽的端口  
##使用说明  
1.在~/.bash_profile文件中设置环境变量SS_SCRIPT_HOME为脚本主目录  
2.在port.dat中添加要监控的端口和最大流量值  
3.运行init.sh  
4.定时运行check-network-flow.sh  
##恢复被屏蔽的端口  
运行resume-port.sh [port]  
##port.dat文件格式  
监控端口 最大流量值（单位为bytes）  
例子  
8080 10240  
8081 2028  
