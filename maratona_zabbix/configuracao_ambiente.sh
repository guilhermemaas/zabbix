#UBUNTU SERVER 18.04
#VMs:
    #Stack/Services Docker: firewall1
        #Grafana:
        #Zabbix-Server:
        #Zabbix-FrontEnd:
    #Proxy Server: docker1
    #PostreSQL: docker2
#MySQL:
    #192.168.0.113 / ilhanublar-desktop
#------------------------------------------
#VM MySQL Zabbix DB:
#------------------------------------------
timedatectl status
timedatectl list-timezones | grep Sao_Paulo
timedatectl set-timezone America/Sao_Paulo
apt search mysql-server
apt install mysql-server
service mysqld status / systemctl status mysqld
systemctl enable --now mariadb.service
mysql_secure_installation #mysql
mysql -u root -p password
create database zabbix character set utf8 collate utf8_bin;
create user 'zabbix'@'localhost' identified by '2maratona@zabbix';
grant all privileges on zabbix.* to 'zabbix'@'localhost';
show databases;
use zabbix;
show tables;
create user 'zabbix'@'%' identified by '2maratona@zabbix';
create user 'zabbix'@'192.168.0.114' identified by '2maratona@zabbix';
#create user 'zabbix'@'192.168.0.114' identified with mysql_native_password by '2maratona@zabbix'; #Criar usuario remoto
#Dica: Criar um usuario para o zabbix server e outro para o zabbix front end.
grant all privileges on zabbix.* to 'zabbix'@'192.168.0.114';
use mysql;
select * from mysql.user;
#drop user 'zabbix'@'192.168.0.114';
UPDATE mysql.user SET Super_Priv='Y' WHERE user='zabbix' AND host='10.0.0.51';
flush privileges;
#firewall-cmd --permanet --add-port=3306/tcp
#Aceitar o MySQL para aceitar conexoes de outros servidores:
    #Comentar a linha abaixo:
    /etc/mysql/mariadb.conf.d/50-server.cnf
    #bind-address            = 127.0.0.1


#------------------------------------------
#VM Docker:
#------------------------------------------
#https://docs.docker.com/engine/install/ubuntu/
timedatectl status
timedatectl list-timezones | grep Sao_Paulo
timedatectl set-timezone America/Sao_Paulo
#Install Docker
service docker status / systemctl status docker
systemctl enable --now docker.service
#CentOS: 
    #firewall-cmd --zone=public --add-masquerade --permanent
    #firewall-cmd --reload
docker info
docker swarm init
docker container ls 
docker network ls
#Verificar se existe conflito entre a rede do ingress e a faixa do server host do docker:
    #for net in `docker network ls | grep -v NAME | awk '{print $2}'`;do ipam=`docker network inspect $net --format {{.IPAM}}` && echo $net -$ipam; done
    docker node ls
    docker node update --availability drain docker1
    docker network rm ingress
    docker network create \
    --driver overlay \
    --ingress \
    --subnet=192.168.102.0/28 \
    --gateway=192.168.102.2 \
    --opt com.docker.network.driver.mtu=1200 \
    ingress
    docker node ls
    docker node update --availability active docker1
#criar rede docker do compose:
docker network create --driver overlay monitoring-network
for net in `docker network ls | grep -v NAME | awk '{print $2}'`;do ipam=`docker network inspect $net --format {{.IPAM}}` && echo $net -$ipam; done
docner network ls
cd /home
pwd
git clone https://github.com/jorgepretel/maratonazabbix.git
#https://github.com/guilhermemaas/maratonazabbix
cd maratonazabbix
sh grafana.sh
ls /mnt/
docker stack deploy -c docker-compose.yaml maratonazabbix
docker stack ls
#NAME                SERVICES            ORCHESTRATOR
#maratonazabbix      3                   Swarm
docker service ls
#docker service rm maratonazabbix
#docker stack rm maratonazabbix
#docker service ps --no-trunc {serviceName}
#sudo ss --tcp --listening --processes --numeric | grep ":2377"
#sudo readlink -f /proc/1229/exe
docker service logs -f maratonazabbix_zabbix-server
#IP VM:80 -> Zabbix
#IP VM:3000 -> Grafana


#------------------------------------------
#Zabbix Proxy:
#------------------------------------------
apt install zabbix-proxy-sqlite3
http://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix/zabbix-proxy-sqlite3_5.0.0-1%2Bbionic_amd64.deb
https://www.zabbix.com/documentation/4.0/manual/installation/install_from_packages/debian_ubuntu #Conforme versao, alterar o diretorio
cd /etc/zabbix
mkdir /var/lib/zabbix
cd /var/lib/
chown zabbix. -R zabbix/
cd /etc/zabbix/
vim zabbix_proxy.conf
    #Proxy operating mode:
        #0 - proxy in the active mode: O proxy inicia a comunicacao com zabbix server.
        #1 - proxy in the passive mode: O Server zabbix inicia a comunicacao com o proxy.
        #Default = 0.
    Server=192.168.0.116
    #ServerPort=10051 #Pode deixar comentado, a requisicao quando chegar no server docker, vai direcionar para o container server-zabbix na porta 10051
    #Hostname=Zabbix proxy #Pode deixar comentado, vai pegar do HostnameItem=system.hostname, que no caso seria o hostname do servidor.
    EnableRemoteCommands=1 #No zabbix proxy nao foi depriciado esse comando como no agent.
    DBName=/var/lib/zabbix/zabbix.db #Tem que remover quando for iniciar o server, ou atualizar.
    DBUser=zabbix
    #DBPassword e ignorado quando e SQLite.
    #ProxyLocalBuffer #Depois que enviar para o Zabbix Server, mantem por x horas.
    ProxyOfflineBuffer=24 #24 horas caso nao consiga comunicacao com o zabbix server.
    ConfigFrequency=300 #Busca quais hosts o proxy vai monitorar no zabbix server. 300 segundos nesse exemplo. Padrao=3600.
    #DataSenderFrequency=1 #Frequencia que o zabbix proxy envia pro zabbix server. Padrao 1, de preferencia deixar assim.
    systemctl enable --now zabbix-proxy #Iniciar junto do SO.
    systemctl status zabbix-proxy
    tail -f /var/log/zabbix/zabbix_proxy.log #log 
    #17504:20200621:213515.521 cannot send proxy data to server at "192.168.0.116": proxy "docker1" not found
    #No Front End do Zabbix > Administration > Proxies > New Proxy
    #Name=system.hostname / Mode=Active
    #Validar coluna Last Seen, caso OK, vai estar alguns segundos.
    systemctl restart zabbix-proxy #Reiniciar depois de alterar o conf.
#Liberar porta 10051 no firewall. Se for CentOS verificar selinux.
apt install firewalld
firewall-cmd --permanent --add-port=10051/tcp


#------------------------------------------
#PostgreSQL Server:
#------------------------------------------
wget http://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix/zabbix-agent2_5.0.0-1%2Bbionic_amd64.deb
dpkg -i zabbix-agent2_5.0.0-1+bionic_amd64.deb
    /etc/zabbix/zabbix_agent2.conf
        Server/ServerActive = IP Server Proxy
        #Hostname=Zabbix server
        HostMetadataItem=system.uname
        Timeout=30
systemctl enable --now zabbix-agent2
systemctl status zabbix-agent2
#Liberar porta 10050 no firewall. Se for CentOS verificar selinux.
apt install firewalld
firewall-cmd --permanent --add-port=10050/tcp
#Adicionar grupo para os servers PostgreSQL
#Adicionar Host PostgreSQL no Zabbix-FrontEnd
    #No servidor de Proxy, testar se o agent no server PostgreSQL esta respondendo:
    zabbix_get -s 192.168.0.116 -p 10050 -k "system.uname" #Se nao tiver: apt install zabbix-get / https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1%2Bbionic_all.deb
apt install postgresql 
ps aux | grep postgresql 
systemctl status postgresql 
nmap -p 5432 localhost
systemctl enable postgresql
#testar a chave proc.num pra pegar se o processo do PostgreSQL esta rodando no server:
    root@docker2:/var/log/zabbix# zabbix_agent2 -t proc.num[,postgres]
    proc.num[,postgres]                          [s|7]
    #No Proxy:
        root@docker1:/var/log/zabbix# zabbix_get -s 192.168.0.116 -p 10050 -k "proc.num[,postgres]"
        7
    #Pegar so o processo do Autovacuum:
    root@docker2:/var/log/zabbix# ps aux| grep postgres | grep autovacuum
    postgres 13512  0.0  0.3 319176  6880 ?        Ss   00:32   0:00 postgres: 10/main: autovacuum launcher process
    root@docker2:/var/log/zabbix# zabbix_agent2 -t proc.num[,postgres,,logger]
    proc.num[,postgres,,logger]                   [s|0]
    #Obs.: Se o "grep" tiver um espaco no nome do processo, tem que colocar entre "" nos parametros da key, exemplo: proc.num[,postgres,,"background writer"]
#Criar um template pra adicionar itens que pegam os status dos processos do PostgreSQL.
#Associar host ao template
#Monitorar a porta do PostgreSQL, 5432/TCP, criar um item pra isso, no template:
    net.tcp.service[service,<ip>,<port>] #sem IP, pois vai ser localhost onde o agent roda.
    #http://192.168.0.114/zabbix.php?action=valuemap.list -> Mapeamento de valores - Show values
    #0 False, 1 True
    #Teste a partir do Proxy:
    root@docker1:/var/log/zabbix# zabbix_get -s 192.168.0.116 -p 10050 -k "net.tcp.service[tcp,,5432]"
    1
#Liberar porta 5432 para outros hosts da rede(Recomendado se o banco estiver atras de um firewall):
    #no pg_hba.conf:
    #host all all 0.0.0.0/0 trust
    #no postgresql.conf
    listen_addresses = '*'
    systemctl restart postgresql
    