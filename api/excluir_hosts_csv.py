import csv
from pyzabbix import ZabbixAPI
from time import sleep


def print_separator() -> str:
    print('-' * 30)


def import_hosts_csv(csv_file) -> list:
    try:
        with open(csv_file) as csv_file:
            hosts_list = []
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:
                print(f'Host importado: {row[0]}')
                hosts_list.append(row[0])
            return hosts_list
    except Exception as error:
        print(error)


def zabbix_delete_hosts(hosts: list, zabbix_api_url: str, zabbix_user: str, zabbix_password: str):
    zabbix_api = ZabbixAPI(zabbix_api_url)
    zabbix_api.login(zabbix_user, zabbix_password)
    print(f'Connected to Zabbix API Version: {zabbix_api.api_version()}')
    
    for host in hosts:
        filter = {'host': host}
        print_separator()
        print(f'Host a ser excluido: {filter}.')
        
        try:
            hostname = zabbix_api.host.get(filter={'host': host}, output=['name', 'hostid', 'status'])
            print(hostname)
            host_del = []
            host_del.append(int(hostname[0]['hostid']))
            print(host_del[0])
        except Exception as error:
            print(error)
        
        try:
            zabbix_api.host.delete(host_del[0])
        except Exception as error:
            print(error)

        print_separator()
        sleep(0.5)


def main():
    csv_path = r'C:\\dev\\zabbix-scripts\\hosts.csv'
    zabbix_api_url = ''
    zabbix_user = ''
    zabbix_password = ''
    hosts = import_hosts_csv(csv_path)
    zabbix_delete_hosts(hosts, zabbix_api_url, zabbix_user, zabbix_password)


if __name__ == '__main__':
    main()