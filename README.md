# For setting up AWS free tier server
Follow these steps
https://medium.com/@lijinlar/free-vpn-server-for-playing-pubg-e8c8d3cdef20

# openvpn-installer
For installing openvpn server on ubuntu 16 os

Clone this repository on your local machine where you downloaded server *pem* file,

```
git clone https://github.com/lijinlar/openvpn-installer.git
cd openvpn-installer
sudo ./install-ovpn.sh <path to pem file> <public-ip of the server> <vpn-client name>
```

After completing this successfully, You'll get a .ovpn file. You can add that configuration to any of the open vpn clients and enjoy browsing.
