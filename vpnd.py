import csv
import random
import base64
import threading
from subprocess import Popen,PIPE
import time

def dump_out(pp):
	while pp.returncode==None:
		ps = pp.stdout.readline()
		ps = ps.strip()
		if len(ps)>0:
			print ps
		pp.poll()
	print pp.returncode

def runvpn(config):
	cf = open('/tmp/vpn.cfg', 'wb');
	cf.write(config)
	cf.close()
	pp = Popen(['/usr/sbin/openvpn', '--config', '/tmp/vpn.cfg', '--dev', 'tun101', '--script-security', '2', '--up', 'unblock_ovpn.sh'], stdout=PIPE)
	bgthread = threading.Thread(target=dump_out, args=(pp,))
	bgthread.start()
	time.sleep(20)
	while testvpn():
		print 'PING OK'
		time.sleep(20)
	try:
		print 'PING FAILED'
		pp.terminate()
	except:
		print 'already dead'
	
def testvpn():
	pp = Popen(['ping', '8.8.8.8', '-I', 'tun101', '-w', '2'])
	pp.wait()
	if pp.returncode==0:
		return True
	else:
		return False

while True:
	with open('vpns.csv','rb') as servers:
		reader = csv.reader(servers, delimiter=',')
		slist = [];
		for row in reader:
			if len(row)>14 and row[2].isdigit():
				slist.append(row)
			else:
				print row
		count=len(slist)
		censors = ['RU', 'KR']
		slist = filter(lambda srv: not (srv[6] in censors), slist)
		slist = sorted(slist, key=lambda srv: srv[2])
		shortlist = slist[0:count/2]
		server = random.choice(shortlist)
		print server[:14]
		config = base64.b64decode(server[14])
		runvpn(config)


