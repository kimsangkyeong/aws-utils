##############################################################################
# 목적 : single thread socket server program                                 #
# 조건 : python3 이상                                                        #
# 예시 : 설명보기 > python echo-server.py -h                                 #
#        Any client listen : python echo-server.py -p 9999                   #
#        local listen : python echo-server.py -i 127.0.0.1 -p 9999           #
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
      { '-i' : ('ip'   , '?', '', 'socket server - listen ipaddress' )},
      { '-p' : ('port' , '?', '9999', 'socket server - listen port' )}
             ]

  parser = argparse.ArgumentParser(description='socket server information')

  for cmdline in cmdlines:
    for key, dtuple in cmdline.items():
      dlist = list(dtuple)
      parser.add_argument(key, dest=dlist[0], nargs=dlist[1], default=dlist[2], help=dlist[3])

  return parser.parse_args()

def main(argv):

  args = cmd_parse()
  HOST = args.ip
  PORT = int(args.port)

  print(" listen  information : '{}' : {} ".format(HOST,PORT))

  # 소켓 객체를 생성합니다. 
  # 주소 체계(address family)로 IPv4, 소켓 타입으로 TCP 사용합니다.  
  server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)


  # 포트 사용중이라 연결할 수 없다는 
  # WinError 10048 에러 해결를 위해 필요합니다. 
  server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)


  # bind 함수는 소켓을 특정 네트워크 인터페이스와 포트 번호에 연결하는데 사용됩니다.
  # HOST는 hostname, ip address, 빈 문자열 ""이 될 수 있습니다.
  # 빈 문자열이면 모든 네트워크 인터페이스로부터의 접속을 허용합니다. 
  # PORT는 1-65535 사이의 숫자를 사용할 수 있습니다.  
  server_socket.bind((HOST, PORT))

  # 서버가 클라이언트의 접속을 허용하도록 합니다. 
  server_socket.listen()

  # accept 함수에서 대기하다가 클라이언트가 접속하면 새로운 소켓을 리턴합니다. 
  client_socket, addr = server_socket.accept()

  # 접속한 클라이언트의 주소입니다.
  print('Connected by', addr)



  # 무한루프를 돌면서 
  while True:

    # 클라이언트가 보낸 메시지를 수신하기 위해 대기합니다. 
    data = client_socket.recv(1024)

    # 빈 문자열을 수신하면 루프를 중지합니다. 
    if not data:
        break


    # 수신받은 문자열을 출력합니다.
    print('Received from', addr, data.decode())

    # 받은 문자열을 다시 클라이언트로 전송해줍니다.(에코) 
    client_socket.sendall(data)


  # 소켓을 닫습니다.
  client_socket.close()
  server_socket.close()

if __name__ == "__main__":
   main(sys.argv[:])

