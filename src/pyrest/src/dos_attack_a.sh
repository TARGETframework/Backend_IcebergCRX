#!/bin/bash
#
# starts the MitM attack via ARP spoofing
docker exec digital_twin screen -S attacker_dos -X stuff "bash attack/dos_attack_a.sh^M"
