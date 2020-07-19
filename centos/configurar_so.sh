#Zabbix-Server: xxx.xxx.x.41 All in one CentOS
#Zabbix-FrontEnd: xxx.xxx.x.42 -> PostgreSQL Server e outros
#MySQLDB: xxx.xxx.x.43 -> MySQLServer e Outros
#Proxy: xxx.xxx.x.44
#APP: xxx.xxx.x.45
#-----------------------------------------------------------------Configuracao do Zabbix All in One CentOS 8 Minimal
timedatectl status
timedatectl set-timezone America/Sao_Paulo
dnf install -y net-tools vim nano epel-release wget curl tcpdump #Novo gerenciador de pacotes (Yum old)
sestatus #Verificar se o selinux esta habilitado
vim /etc/selinux/config #Desabilitar o selinux
    #SELINUX=enforcing #comentar
setenforce=0 #Teria que reiniciar, mas com esse comando desabilita
getenforce #ou sestatus para validar, tem que estar como permissive
dnf info mysql-server
dnf install -y mysql-server #-y yes to all questions
systemctl enable --now mysqld #Configurar para iniciar junto do boot e starta
systemctl status mysqld
mysql_secure_installation #xx.xx.xx.mysql
mysql -u root -p 
create database zabbix character set utf8 collate utf8_bin;
create user 'zabbix'@'localhost' identified by 'cursozabbix5';
grant all privileges on zabbix.* to 'zabbix'@'localhost';
flush privileges;
mysql -u zabbix -p zabbix #-p pra pedir senha, zabbix database
rpm -ivh http://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm #Instalacao do repo
#http://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/
rpm -qa | grep zabbix #Verifica se foi instalado
dnf clean all #Limpar os repos que ja existem
dnf -y install zabbix-server
Installed:
OpenIPMI-libs-2.0.27-1.el8.x86_64          fping-4.2-2.el8.x86_64               libtool-ltdl-2.4.6-25.el8.x86_64                mariadb-connector-c-3.0.7-1.el8.x86_64         
net-snmp-libs-1:5.8-14.el8.x86_64          unixODBC-2.3.7-1.el8.x86_64          zabbix-server-mysql-5.0.2-1.el8.x86_64 
#Popular a base do zabbix, com baser nas docs do Zabbix:
zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -u zabbix -p zabbix
#Validar as tabelas
mysql -u zabbix -p zabbix
show tables; #166
vim /etc/zabbix/zabbix_server.conf
DBPassword=cursozabbix5
systemctl enable --now zabbix-server
#Instalar o frontend:
dnf -y install zabbix-web-mysql zabbix-apache-conf
vim /etc/php-fpm.d/zabbix.conf #Ajustar o timezone do arquivo de config do Zabbix pra America/Sao_Paulo
systemctl enable --now httpd php-fpm
systemctl status httpd php-fpm #php-fpm PHP FastCGI Process Manager
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload