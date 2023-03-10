#!/usr/bin/bash


function action_up()
{
  # Create new chain
  iptables -t nat -N REDSOCKS

  # Exclude local and reserved addresses
  iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
  iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
  iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
  iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
  iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
  iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
  iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
  iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN

  iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345

  # Redirect all HTTP and HTTPS outgoing packets through Redsocks
  iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDSOCKS
  iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDSOCKS

  iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDSOCKS
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDSOCKS
  iptables -t nat -A PREROUTING -p tcp --dport 1080 -j REDSOCKS
}

function action_down()
{
  iptables -v -t nat -D OUTPUT -p tcp -j REDSOCKS

  iptables -v -F REDSOCKS -t nat
  iptables -v -X REDSOCKS -t nat
}


trap 'action_down' SIGINT

action_up

echo
echo "Hit Ctrl+C to remove the ip table rules"
echo


while :
do
    sleep 1
done
