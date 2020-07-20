from pyzabbix import ZabbixAPI
from dicttoxml import dicttoxml
import sys
from time import sleep

api_url = 'http://localhost/api_jsonrpc.php'
user_login = 'Admin'
user_password= 'zabbix'

zapi = ZabbixAPI(api_url)
zapi.login(user_login, user_password)
print("Connected to Zabbix API Version %s" % zapi.api_version())

def printa_separador() -> str:
    print('-'*30)


user_group_id = 8 #id do grupo que vai ser alterado
new_refresh_time = 350 #novo parâmetro refreshtime

printa_separador()
grup_zabbix = zapi.usergroup.get(output='extend', usrgrpids=user_group_id)
print(f"ID do grupo selecionado: {grup_zabbix[0]['usrgrpid']}")
print(f"Nome do grupo selecionado: {grup_zabbix[0]['name']}")
printa_separador()
printa_separador()


for u in zapi.user.get(output='extend', usrgrpids=user_group_id):
    print(f"ID do usuário selecionado: {u['userid']}")
    print(f"ID do usuário selecionado: {u['alias']}")
    print('Realizado update de refresh:')
    sleep(0.2)
    print(f"Pârametro Refresh Atual: {u['refresh']}")
    zapi.user.update(userid=u['userid'], refresh=new_refresh_time)
    print(f'Pârametro Refresh para: {new_refresh_time}')
    printa_separador()