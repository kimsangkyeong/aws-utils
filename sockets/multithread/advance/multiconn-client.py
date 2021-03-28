##############################################################################
# 목적 : multithread socket client program (default : 127.0.0.1)             #
# 조건 : python3 이상                                                        #
# 예시 : 설명보기 > python multiconn-client.py -h                            #
#        python multiconn-client.py -n google.com -p 9999                    #
#        python multiconn-client.py -i 10.2.1.156 -p 9999                    #
# -------------------------------------------------------------------------- #
#  ver       date       author       description                             #
# -------------------------------------------------------------------------- #
#  1.0    2021.3.28      ksk         최초 개발                               #
##############################################################################
import sys, getopt
import argparse
import socket

def cmd_parse():
  cmdlines = [
      # data means => 0:option, 1:dest , 2:nargs , 3:default , 4:help
      { '-n' : ('hostname', '?', 'none', 'socket hostname to connect server ' )},
      { '-i' : ('ip'   , '?', '127.0.0.1', 'socket ipaddress to connect server ' )},
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

  PORT = int(args.port)
  if args.hostname != 'none':
    HOST = socket.gethostbyname(args.hostname)
    print(" hostname connect >> {} - {} : {} ".format(args.hostname,HOST,PORT))
  else:
    HOST = args.ip
    print(" ip connect >> {} : {} ".format(HOST,PORT))

  # 소켓 객체를 생성합니다.
  # 주소 체계(address family)로 IPv4, 소켓 타입으로 TCP 사용합니다.
  client_socket = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

  # 지정한 HOST와 PORT를 사용하여 서버에 접속합니다.
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

