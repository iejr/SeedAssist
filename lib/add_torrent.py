import sys
from transmission_rpc import Client

Host="127.0.0.1"
Port=9091
Username=""
Password=""

def InitTr(hostname=Host, port=Port, username=Username, password=Password):
  client = Client(host=hostname, port=port, username=username, password=password)
  return client

def AddTorrent(client, torrent_file, complete_dir):
  with open(torrent_file, 'rb') as fin:
    client.add_torrent(fin, download_dir=complete_dir)

if __name__ == '__main__':
  if len(sys.argv) != 7:
    print("Usage: python add_torrent.py hostname port username password torrent_file complete_dir")
    exit(1)

  hostname  = sys.argv[1]
  port = sys.argv[2]
  username = sys.argv[3]
  password = sys.argv[4]
  torrent_file = sys.argv[5]
  complete_dir = sys.argv[6]

  client = InitTr(hostname, port, username, password)
  AddTorrent(client, torrent_file, complete_dir)
