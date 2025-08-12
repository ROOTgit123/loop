import socket

UDP_IP = "0.0.0.0"
UDP_PORT = 5005

# Simple user:pass dictionary
VALID_USERS = {
    "user": "pass",
    "admin": "admin123"
}

# Store client info after auth: {id: (user, ip, port)}
connected_clients = {}

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))
print(f"UDP server listening on {UDP_IP}:{UDP_PORT}")

while True:
    data, addr = sock.recvfrom(1024)
    message = data.decode("utf-8").strip()
    print(f"Received message: {message} from {addr}")

    try:
        header, _, payload = message.partition(' ')
        if '@' not in header or ':' not in header:
            raise ValueError("Invalid header format")

        id_part, auth_part = header.split('@', 1)
        user, passwd = auth_part.split(':', 1)

        if VALID_USERS.get(user) == passwd:
            # Save client info by id
            connected_clients[id_part] = (user, addr[0], addr[1])
            response = f"Authorized - ID:{id_part} Payload:{payload}"
        else:
            response = "Unauthorized"
    except Exception as e:
        response = f"Error: {str(e)}"

    sock.sendto(response.encode(), addr)
    print(f"Sent back: {response} to {addr}")
    print(f"Connected clients: {connected_clients}")
