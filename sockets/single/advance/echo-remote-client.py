#
# echo-remote-client.py
#
# https://webnautes.tistory.com/1381
#

import sys, getopt
import argparse
import socket

def cmd_parse():
  cmdlines = [
      # data means => 0:option, 1:dest , 2:nargs , 3:default , 4:help
      { '-i' : ('ip'   , '?', '100.64.17.136', 'socket ipaddress to connect server ' )},
      { '-p' : ('port' , '?', '9999', 'socket port to connect server' )}
             ]

  parser = argparse.ArgumentParser(description='socket client information')

  for cmdline in cmdlines:
    for key, dtuple in cmdline.items():
      dlist = list(dtuple)
      parser.add_argument(key, dest=dlist[0], nargs=dlist[1], default=dlist[2], help=dlist[3])

  return parser.parse_args()


def main(argv):

  args = cmd_parse()
  HOST = args.ip
  PORT = int(args.port)

  print(" connect : {} : {} ".format(HOST,PORT))
 
  # 소켓 객체를 생성합니다. 
  # 주소 체계(address family)로 IPv4, 소켓 타입으로 TCP 사용합니다.  
  client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  
  print(" socket init  success ", client_socket)
  
  # 지정한 HOST와 PORT를 사용하여 서버에 접속합니다. 
  client_socket.connect((HOST, PORT))
  
  print(" socket connect success ")
  
  # 메시지를 전송합니다. 
  client_socket.sendall('안녕'.encode())
  
  # 메시지를 수신합니다. 
  data = client_socket.recv(1024)
  print('Received', repr(data.decode()))
  
  # 소켓을 닫습니다.
  client_socket.close()
  
if __name__ == "__main__":
   main(sys.argv[:])
