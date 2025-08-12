import socket

UDP_IP = "127.0.0.1"  # Server IP
UDP_PORT = 5005

user = "user"
password = "pass"
id_num = 123
payload = "Hello from client"

message = f"id:{id_num}@{user}:{password} {payload}"
data = message.encode('utf-8')

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.sendto(data, (UDP_IP, UDP_PORT))

print(f"Sent: {message} to {UDP_IP}:{UDP_PORT}")

response, addr = sock.recvfrom(1024)
print(f"Received response: {response.decode('utf-8')} from {addr}")

