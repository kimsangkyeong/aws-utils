##############################################################################
# 목적 : multithread socket server program                                   #
# 조건 : python3 이상                                                        #
# 예시 : 설명보기 > python multiconn-server.py -h                            #
#        Any client listen : python multiconn-server.py -p 9999              #
#        local listen : python multiconn-server.py -i 127.0.0.1 -p 9999      #
# -------------------------------------------------------------------------- #
#  ver       date       author       description                             #
# -------------------------------------------------------------------------- #
#  1.0    2021.3.28      ksk         최초 개발                               #
##############################################################################
import sys, getopt
import argparse
import socket
from _thread import *

def cmd_parse():
  cmdlines = [
      # data means => 0:option, 1:dest , 2:nargs , 3:default , 4:help
      { '-i' : ('ip'   , '?', '', 'socket server - listen ipaddress' )},
      { '-p' : ('port' , '?', '9999', 'socket server - listen port' )}
             ]

  parser = argparse.ArgumentParser(description='socket server information')

  for cmdline in cmdlines:
    for key, dtuple in cmdline.items():
      dlist = list(dtuple)
      parser.add_argument(key, dest=dlist[0], nargs=dlist[1], default=dlist[2], help=dlist[3])

  return parser.parse_args()


# 쓰레드에서 실행되는 코드입니다.

# 접속한 클라이언트마다 새로운 쓰레드가 생성되어 통신을 하게 됩니다.
def threaded(client_socket, addr):

    print('Connected by :', addr[0], ':', addr[1])

    # 클라이언트가 접속을 끊을 때 까지 반복합니다.
    while True:

        try:

            # 데이터가 수신되면 클라이언트에 다시 전송합니다.(에코)
            data = client_socket.recv(1024)

            if not data:
                print('Disconnected by ' + addr[0],':',addr[1])
                break

            print('Received from ' + addr[0],':',addr[1] , data.decode())

            client_socket.send(data)

        except ConnectionResetError as e:

            print('Disconnected by ' + addr[0],':',addr[1])
            break

    client_socket.close()


def main(argv):

  args = cmd_parse()

  HOST = args.ip
  PORT = int(args.port)

  print(" listen  information : '{}' : {} ".format(HOST,PORT))

  server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  server_socket.bind((HOST, PORT))
  server_socket.listen()
  
  print('server start')
  
  
  # 클라이언트가 접속하면 accept 함수에서 새로운 소켓을 리턴합니다.
  
  # 새로운 쓰레드에서 해당 소켓을 사용하여 통신을 하게 됩니다.
  while True:
  
      print('wait')
  
  
      client_socket, addr = server_socket.accept()
      start_new_thread(threaded, (client_socket, addr))
  
  server_socket.close()

if __name__ == "__main__":
   main(sys.argv[:])

