#!/bin/bash

########################################
# extremely simplified bootstrap script
# author: fabien.malfoy@startx.fr
# author: fcami@redhat.com
########################################

########################################
# normal configuration
########################################
#-- Satellite/Spacewalk FQDN
mysat=""
#-- Comma separated (no spaces) list of activation
#-- keys including the organization ID (eg. 2-default)
keys=""
#-- Yum update upon registration completion
full_update=no
#-- Enable configuration channel client tools features
config_actions=no
#-- Enable remote commands execution
remote_commands=no
#-- Space separated list of GPG (or SSL) keys
#-- to retrieve and import
listofgpgkeys=""
#-- Space separated list of packages names
#-- to install after registration
packages_to_install=""
########################################

########################################
# advanced configuration - do not modify
########################################
ssl_cert="RHN-ORG-TRUSTED-SSL-CERT"
ssl_cert_rpm="rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm"
dest_dir="/usr/share/rhn"
mandatory_packages="rhn-check yum-rhn-plugin rhn-client-tools rhn-setup"
########################################

########################################
# script itself
########################################

printf "################ Spacewalk registration ################\n\n"

# check availability of rhn packages
if ! (rpm -q ${mandatory_packages}); then
  printf "==> \e[31;1mFATAL ERROR\e[0m: Please install missing packages first.\n"
  printf "==> INFO: Packages = '\e[4mnot installed\e[0m' listed above\n"
  exit 1
fi

# remove subscription-manager
if rpm -q --quiet subscription-manager; then
  if subscription-manager identity &> /dev/null; then
    printf "==> INFO: System already registered with subscription-manager.\n"
    printf "==> INFO: Unregistering it...\n"
    subscription-manager unregister
  fi
  yum -q -y remove subscription-manager
fi

# remove yum proxy configuration
sed -i -e 's/^proxy.*//g' /etc/yum.conf
sed -i -e 's/^# Proxy.*//g' /etc/yum.conf

# get Satellite SSL certificate
curl -s http://${mysat}/pub/${ssl_cert_rpm} -o /tmp/${ssl_cert_rpm}
yum -q -y install /tmp/${ssl_cert_rpm}

# set serverURL and sslCACert to appropriate values
sed -i -e "s,serverURL=.*,serverURL=https://${mysat}/XMLRPC,g" /etc/sysconfig/rhn/up2date
sed -i -e "s,sslCACert=.*,sslCACert=${dest_dir}/${ssl_cert},g" /etc/sysconfig/rhn/up2date

# import GPG KEYS
for gpgkey in ${listofgpgkeys}; do
  rpm --import  http://${mysat}/pub/${gpgkey}
done

# register your server
printf "==> INFO: Registering into Spacewalk...\n"
printf "==> INFO: Keys = ${keys}...\n"
/usr/sbin/rhnreg_ks --activationkey=${keys}
yum -q clean all

# install all necessary packages
if [ -n "$packages_to_install" ]; then
  printf "==> INFO: Installing additional packages...\n"
  printf "==> INFO: Packages = ${packages_to_install}...\n"
  yum -q -y install ${packages_to_install} --skip-broken
fi

# update
if [ "$full_update" == "yes" ]; then
  printf "==> INFO: Performing packages update...\n"
  if yum list updates kernel &> /dev/null; then
    printf "==> \e[31;1mWARNING\e[0m: Updating kernel. "
    printf "Please \e[31;1mreboot\e[0m after registration.\n"
  fi
  yum -y update &> /dev/null
fi

# rhncfg-client
if [ "$config_actions" == "yes" ]; then
  printf "==> INFO: Enabling configuration management...\n"
  rhn-actions-control --enable-{deploy,diff,{,mtime-}upload}
fi

# remote commands
if [ "$remote_commands" == "yes" ]; then
  printf "==> INFO: Enabling remote commands...\n"
  rhn-actions-control --enable-run
fi

# osad activation
if rpm -q --quiet osad; then
  chkconfig osad on &> /dev/null
  service osad start &> /dev/null

  # schedule daily osad restart
  > /etc/cron.d/osad-restart cat <<-EOF
	50 23 * * * root service osad restart
	EOF
fi

printf "\n################   \e[32mSystem registered!\e[0m   ################\n"
########################################
