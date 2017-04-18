#/bin/sh
# Simple script to restart SSH tunnel whenever it is broken
# Cron job should execute this script every xx minutes

if [[ $(ps -ef | grep -c 5555)  -eq 1 ]]; then
ssh -nNT -R 5555:localhost:<FrontGun_IP>
fi
