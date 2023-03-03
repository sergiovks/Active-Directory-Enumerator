#!/bin/bash

# Example script to enumerate an Active Directory with ldapsearch

# Set connection variables
# ldap_server="domain-controller.example.com"
# ldap_user="ldapsearch-user"
# domain="example.com"
# password="user-password"

# Set search base
search_base="dc=example,dc=com"

# Define function to display help panel
display_help() {
  echo "Usage: $0 [-h] [-lds ldap-server ldap-user] [-d domain] [-p password]"
  echo "Active Directory enumeration script using ldapsearch"
  echo " "
  echo "Options:"
  echo "-h, --help                show help panel"
  echo "-lds, --ldap-server       LDAP server to connect to, f. ex: domain-controller.example.com"
  echo "-ldu, --ldap-user         LDAP user for authentication, f. ex: billy"
  echo "-d, --domain              AD domain to search, f. ex: example.com"
  echo "-p, --password            Password for LDAP user, f. ex: 123456789"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    display_help
    exit 0
    ;;
    -lds|--ldap-server)
    ldap_server="$2"
    shift # past argument
    shift # past value
    ;;
    -ldu|--ldap-user)
    ldap_user="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--domain)
    domain="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--password)
    password="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Invalid option: $key"
    display_help
    exit 1
    ;;
esac
done

# Check that all required arguments are set
if [[ -z "$ldap_server" || -z "$ldap_user" || -z "$domain" || -z "$password" ]]; then
    display_help
    exit 1
fi

# Determine search base using ldapsearch command
dn=$(ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "" -s base "(objectClass=*)" dn | awk '/dn: / {print $2}')

# Set search base
search_base="$dn"

# Search for all users
echo "Users:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=user)(sAMAccountName=*))"

# Search for all groups
echo "Groups:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=group)(cn=*))"
 
# Search for all computers
echo "Computers:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=computer)(cn=*))"
 
# Search for all contacts
echo "Contacts:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=contact)(cn=*))"
 
# Search for all site objects
echo "Site objects:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=site)(cn=*))"
 
# Search for all service objects
echo "Service objects:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=service)(cn=*))"
 
# Search for all GPO objects
echo "GPO objects:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=groupPolicyContainer)(cn=*))"
 
# Search for all OU objects
echo "OU objects:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=organizationalUnit)(cn=*))"
 
# Search for all domain objects
echo "Domain objects:"
ldapsearch -x -h "$ldap_server" -D "$ldap_user@$domain" -w "$password" -b "$search_base" -LLL -s sub "(&(objectClass=domain)(dc=*))"
