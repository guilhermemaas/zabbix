import requests

class LoginApiZabbix:
    def __init__(self, api_url: str, api_user: str, api_password: str):
        self.api_url = api_url
        self.api_user = api_user
        self.api_password = api_password

    def init_session(self) -> str:
        response = requests.post(self.api_url, json={
            'jsonrpc': '2.0',
            'method': 'user.login',
            'params': {
                'user': f'{self.api_user}',
                'password': f'{self.api_password}'
            },
            'id': 1
            })
        return response.json()['result']


def main():
    zabbix_api = LoginApiZabbix('http://endereco/api_jsonrpc.php', 'user', 'pass')
    zabbix_login_token = zabbix_api.init_session()

    response = requests.post(zabbix_api.api_url, json={
    'jsonrpc': '2.0',
    'method': 'item.get',
    'params': {
        'output': 'extend',
        'hostids': '28209' #RT-EDGE-CUA_C2-1
    },
    'auth': zabbix_login_token,
    'id': 1
    })

    print(response.elapsed.total_seconds())


if __name__ == '__main__':
    main()
