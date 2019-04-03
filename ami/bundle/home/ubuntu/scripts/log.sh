#!/bin/bash
journalctl -u sassy-machine-api.service -f -n 10000 | grep "\(streaming package to machine\)\|\(sync:$1:\)\|\(id:$1\\s\)\|\(tunnel\(\(.101\)\|\:\)\)"
