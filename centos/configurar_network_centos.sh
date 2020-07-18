#Zabbix-Server: xxx.xxx.x.41 ok
#Zabbix-FrontEnd: xxx.xxx.x.42
#MySQLDB: xxx.xxx.x.43
#Proxy: xxx.xxx.x.44
#APP: xxx.xxx.x.45

#Configurar placa de rede
vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
NM_CONTROLLED=yes
TYPE=Ethernet
BOOTPROTO=static
NAME=y
UUID=x
DEVICE=z
ONBOOT=yes
IPADDR=192.168.0.41
NETMASK=255.255.255.0
DNS1=192.168.0.1

#Configurar rede/geral:
vi /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=xpto
GATEWAY=192.168.0.1

#Adicionar rota pra internet:
route add -net 0.0.0.0/0 gw 192.168.0.1
netstat -nr #Pra verificar as rotas

#Reiniciar servidor de rede:
systemctl restart NetworkManager.service