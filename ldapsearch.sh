#!/bin/bash

# Example script to enumerate an Active Directory with ldapsearch

# Set connection variables
ldap_server="domain-controller.example.com"
ldap_user="ldapsearch-user"
domain="example.com"
password="user-password"

# Set search base
search_base="dc=example,dc=com"

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
