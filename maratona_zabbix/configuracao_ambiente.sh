#UBUNTU SERVER 18.04
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
#------------------------------------------
#VM Docker:
#------------------------------------------
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