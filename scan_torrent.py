import subprocess
import sys
import transmission_rpc

Host="127.0.0.1"
Port=9091
Username=""
Password=""

def test():
  ret = subprocess.run(['rm', 'testfile'], stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding="utf-8")
  print(ret.returncode)


def main():
  client = transmission_rpc.Client(host=Host, port=Port, username=Username, password=Password)
  torrent_list = client.get_torrents(arguments=['id', 'name', 'status', 'hashString', 'downloadDir'])

  for torrent in torrent_list:
    if "/home/vdisk0/PT/Complete/Movie" in torrent.downloadDir and torrent.status is not 'stopped':
      print(torrent.name + ": " + torrent.downloadDir)
      ret = subprocess.run(['/usr/bin/bash', 'seed_transfer.sh', torrent.name, 'User@Hostname', torrent.downloadDir, torrent.hashString], stdout=subprocess.PIPE,stderr=subprocess.PIPE,encoding="utf-8")
      if ret.returncode is 0:
        print("success")
        client.stop_torrent(torrent.hashString)
      else:
        print(ret)
        break;


if __name__ == '__main__':
  main()
