#
# multiconn-client.py
#
#
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

  client_socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
  
  client_socket.connect((HOST, PORT))
  
  
  
  # 키보드로 입력한 문자열을 서버로 전송하고
  
  # 서버에서 에코되어 돌아오는 메시지를 받으면 화면에 출력합니다.
  
  # quit를 입력할 때 까지 반복합니다.
  while True:
  
      message = input('Enter Message : ')
      if message == 'quit':
      	break
  
      client_socket.send(message.encode())
      data = client_socket.recv(1024)
  
      print('Received from the server :',repr(data.decode()))
  
  
  client_socket.close()

if __name__ == "__main__":
   main(sys.argv[:])

