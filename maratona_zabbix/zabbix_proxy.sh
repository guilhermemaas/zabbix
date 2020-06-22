#------------------------------------------
#Zabbix Proxy-App:
#------------------------------------------
ProxyMode=0
Server=<IP_SERVER>
#Hostname=Zabbix Proxy
EnableRemoteCommands=1
DBName=/var/lib/zabbix/zabbix.db 
DBUser=zabbix
ProxyOfflineBuffer=24
ConfigFrequency=300
DataSenderFrequency=1
