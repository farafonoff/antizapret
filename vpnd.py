from __future__ import print_function
import csv
import random
import base64
import threading
# import httplib2
import http.client
from subprocess import Popen, PIPE
import time
import traceback

censors = ['RU', 'KR']
# httpcli = httplib2.Http(".cache")


def dump_out(pp):
    while pp.returncode == None:
        ps = pp.stdout.readline()
        ps = ps.strip()
        if len(ps) > 0:
            print(ps)
        pp.poll()
    print(pp.returncode)


def runvpn(config):
    cf = open('/tmp/vpn.cfg', 'wb')
    cf.write(config)
    cf.close()
    pp = Popen(
        ['/usr/sbin/openvpn', '--config', '/tmp/vpn.cfg', '--dev', 'tun101', '--script-security',
         '2', '--route-noexec', '--up', 'unblock_ovpn.sh', '--down', 'downvpn.sh'], stdout=PIPE)
    bgthread = threading.Thread(target=dump_out, args=(pp,))
    bgthread.start()
    time.sleep(40)
    while testvpn():
        print('PING OK')
        time.sleep(20)
    try:
        print('PING FAILED')
        pp.terminate()
    except:
        print ('already dead')


def testvpn():
    pp = Popen(['ping', '8.8.8.8', '-I', 'tun101', '-w', '3'])
    pp.wait()
    if pp.returncode == 0:
        return True
    else:
        return False


def newservlist():
    # src = 'http://www.vpngate.net/api/iphone/'
    host = 'www.vpngate.net'
    path = '/api/iphone/'
    conn = http.client.HTTPConnection(host, 80, timeout=10)
    conn.request("GET", path)
    response = conn.getresponse()
    print(response.status, response.reason)
    content = response.read()
    content = content
    #(resp, content) = httpcli.request(src)
    lines = content.splitlines()
    return map(str, lines)


def pickAndConnect(serversList):
    reader = csv.reader(serversList, delimiter=',')
    slist = []
    for row in reader:
        if len(row) > 14 and row[2].isdigit():
            slist.append(row)
        else:
            print(row)
    count = len(slist)
    slist = filter(lambda srv: not (srv[6] in censors), slist)
    slist = sorted(slist, key=lambda srv: srv[2])
    print('total items: ', len(slist))
    server = random.choice(slist)
    #print(server[:14])
    config = base64.b64decode(server[14])
    runvpn(config)

while True:
    try:
        print('GET SERVER LIST...')
        lines = newservlist()
        pickAndConnect(lines)
    except Exception as e:
        print('FAIL')
        traceback.print_exc()
        print(e)
        time.sleep(10)
