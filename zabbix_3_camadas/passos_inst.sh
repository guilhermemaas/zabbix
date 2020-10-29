#MariaDB Server: 192.168.0.118
#Zabbix Server: 192.168.0.117
#Zabbix Web: 192.168.0.119

#Verificar o timezone atual configurado no servidor:
timedatectl status

#Configurar o timezone para Sao Paulo:
timedatectl set-timezone Amercia/Sao_Paulo

#Listar todos os timezones disponives:
timedatectl list-timezones

#Verificar hora atual:
date

#Configurar o chrony(Client NTP) para corrigir data e hora:
dnf -y install chrony

#Habilitar o Chrony
systemctl enable --now chronyd

#Validar os servers NTP disponiveis:
chronyc sources

#Sincronizar data e hora:
service chronyd restart

#Validar horario:
date

#O Chrony vai atualizar o horario a cada 64 segundos.

#Adicionar regra no firewall para o NTP:
firewall-cmd --permanent --add-service=ntp
firewall-cmd --reload

#Instalar algumas ferramentas basicas:
dnf install -y net-tools vim nano epel-release wget curl tcpdump

#Desativar o selinux:

#Verificar status:
getenforce

#Com reboot:
vim /etc/selinux/config
SELINUX=disabled

#Sem reboot:
setenforce 0
getenforce

#===MARIADB

#Checar versao disponivel do MariaDB Server:
dnf info mariadb-server

#Instalar o MariaDB:
dnf -y install mariadb-server

#Habilitar o servico do MariaDB:
systemctl enable --now mariadb
systemctl status mariadb

#Definir senha do usuario root do MySQL:
mysql_secure_installation

#Conectar ao banco de dados e criar o usuario e banco de dados zabbix:
mysql -u root -p
create database zabbix character set utf8 collate utf8_bin;
create user 'zabbix'@'localhost' identified by 'xpto';
grant all privileges on zabbix.* to 'zabbix'@'localhost';
flush privileges;

#Criar acesso a partir do Zabbix Server:
create user 'zabbix_server'@'192.168.0.117' identified by 'xpto';
grant all privileges on zabbix.* to 'zabbix_server'@'192.168.0.117';
flush privileges;

#Criar acesso a partir do Zabbix Front End:
create user 'zabbix_web'@'192.168.0.119' identified by 'xpto';
grant all privileges on zabbix.* to 'zabbix_web'@'192.168.0.119';
flush privileges;

#Criar regra no firewall pra liberar a porta 3306:
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload

#Liberar MariaDB para aceitar conexoes remotas:
vim /etc/my.cnf.d/mariadb-server.cnf
bind-address = SERVERIP

#Reiniciar servico:
systemctl restart mariadb

#===ZABBIX-SERVER:

#Instalar o repositorio oficial:
rpm -ivh http://repo.zabbix.com/zabbix/5.2/rhel/8/x86_64/zabbix-release-5.2-1.el8.noarch.rpm

#Limpar o cache e remover repositorios antigos:
dnf clean all

#Instalar o Zabbix Server
dnf -y install zabbix-server

#Instalar o client do MariaDB:
dnf -y install mariadb

#Carregar a estrutura/esquema incial do banco de dados:
zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -h 192.168.0.118 -u zabbix_server -p zabbix

#Verificar se as tabelas foram criadas:
mysql -u root -p
use zabbix;
show tables;

#Editar o password no arquivo de configuracao do Zabbix Server:
vim /etczabbix/zabbix_server.conf 

DBHost=192.168.0.118
DBUser=zabbix_server
DBPassword=xpto

#Verificar se nao esta logando erros:
tail -f -n 20 /var/log/zabbix/zabbix_server.log

#Criar regra no Firewall:
firewall-cmd --permanent --add-port=10051/tcp
firewall-cmd --reload


#===ZABBIX FRONT END

#Instalar o repositorio oficial:
rpm -ivh http://repo.zabbix.com/zabbix/5.2/rhel/8/x86_64/zabbix-release-5.2-1.el8.noarch.rpm

#Limpar cache e remover repositorios antigos:
dnf clean all

#Instalar os pacotes:
dnf -y install zabbix-web-mysql zabbix-nginx-conf

#Configurando o PHP:
vim /etc/php-fpm.d/zabbix.conf
php_value[date.timezone] = America/Sao_Paulo

#Habilitar a inicializacao do servico:
systemctl enable --now httpd php-fpm
systemctl status httpd php-fpm

#Acessar a interface Web:
http://IP/zabbix
User: Admin
Pass: zabbix