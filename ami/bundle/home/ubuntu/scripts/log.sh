#!/bin/bash
tail -f -n 10000 /var/log/www/sassy-backend.log | grep "\(streaming package to machine\)\|\(sync:$1:\)\|\(id:$1\\s\)\|\(tunnel\(\(.101\)\|\:\)\)"
