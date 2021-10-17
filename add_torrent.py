import sys
from transmission_rpc import Client

# Host="127.0.0.1"
Port=9091
Username=""
Password=""

def AddTorrent(hostname, torrent_file, complete_dir):
  client = Client(host=hostname, port=Port, username=Username, password=Password)

  with open(torrent_file, 'rb') as fin:
    client.add_torrent(fin, download_dir=complete_dir)

if __name__ == '__main__':
  if len(sys.argv) != 4:
    print("Usage: python add_torrent.py hostname torrent_file complete_dir")
    exit(1)

  hostname  = sys.argv[1]
  torrent_file = sys.argv[2]
  complete_dir = sys.argv[3]

  AddTorrent(hostname, torrent_file, complete_dir)
