#postgreSQL
yum install apel-release
yum install yum-utils -y
#Desabilitar o modulo do PostgreSQL atual no dnf:
sudo dnf -qy module disable postgresql
#instalar o pacote do postgresql, manualmente:
dnf install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
#Habilitar:
yum-config-manager --enable pgdg12
#Instalar:
yum install postgresql12-server postgresql12
#Inicilizar manualmente o Postgresql, primeira vez, recomendado:
/usr/pgsql-12/bin/postgresql-12-setup initdb
#Habilitar inicializacao:
systemctl enable --now postgresql-12
sudo -u postgres createuser --pwprompt zabbix
#zabbix (pass)
sudo -u postgres createdb -O zabbix -E Unicode -T template0 zabbix
#Alterar senha do usuario postgres
su - postgres
psql -c "alter user postgres with password 'postgres'"
#Alterar os metodos de autenticacao para md5(Method) para IPv4 e IPv6:
vim /var/lib/pgsql/12/data/pg_hba.conf
#Garantir que esta liberado para 5432 a porta, e listen_addresses= 'localhost', esta instalacao e allinone:
vim /var/lib/pgsql/12/data/postgresql.conf

#Zabbix:
#Baixar o pacote do Zabbix 5.x:
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
#Instalar:
dnf install zabbix-server-pgsql zabbix-web-pgsql zabbix-nginx-conf zabbix-agent
#Popular a base do Zabbix:
zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | sudo -u zabbix psql zabbix
#Ajustar parametros no zabbix_server.conf:
vim /etc/zabbix/zabbix_server.conf
#DBPassword, #DBPort
#Ajustar o arquivo de conf do zabbix no nginx:
vim /etc/nginx/conf.d/zabbix.conf #Descomentar a linha de port listen
#Ajustar arquivo de conf do PHP:
vim /etc/php-fpm.d/zabbix.conf
#php_value[date.timezone] = America/Sao_Paulo
#Iniciar o service ja verificando o log:
systemctl restart zabbix-server zabbix-agent nginx php-fpm && tail -f /var/log/zabbix/