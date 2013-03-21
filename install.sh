#!/bin/bash

# <udf name="hostname" label="Hostname">
# <udf name="default_ruby_interpreter" label="Default Ruby Interpreter"
#   oneOf="ruby-1.8.6,ruby-1.8.7,ruby-1.9.1,ruby-1.9.2,ruby-head" 
#   default="ruby-1.9.2">

logfile=/tmp/chef.log

echo "Setting locales (fr_FR.UTF-8)" >> $logfile
aptitude -y update
aptitude -y install locales
# Set locales to fr_FR.UTF-8
localedev -i fr_FR -c -f UTF-8 fr_FR.UTF-8
localgen

echo "Upgrading packages" >> $logfile
aptitude -y upgrade

#echo "Setting hostname to {$HOSTNAME}" >> $logfile
#echo ${HOSTNAME} > /etc/hostname
#hostname -F /etc/hostname

echo "Installing RVM and Ruby dependencies" >> $logfile
apt-get -y install curl git-core bzip2 build-essential zlib1g-dev libssl-dev

echo "Installing RVM system-wide" >> $logfile
bash -c "bash <( curl -L https://raw.github.com/wayneeseguin/rvm/stable/binscripts/rvm-installer ) --version 'stable'"
cat >> /etc/profile <<'EOF'
# Load RVM if it is installed,
#  first try to load  user install
#  then try to load root install, if user install is not there.
if [ -s "$HOME/.rvm/scripts/rvm" ] ; then
  . "$HOME/.rvm/scripts/rvm"
elif [ -s "/usr/local/rvm/scripts/rvm" ] ; then
  . "/usr/local/rvm/scripts/rvm"
fi
EOF

source /etc/profile

echo "Installing Ruby interpreter (${DEFAULT_RUBY_INTERPRETER})" >> $logfile
rvm install ${DEFAULT_RUBY_INTERPRETER}
rvm use ${DEFAULT_RUBY_INTERPRETER} --default

echo "Installing Chef" >> $logfile
gem install chef

echo "Configuring Chef solo" >> $logfile
mkdir /etc/chef
cat >> /etc/chef/solo.rb <<EOF
file_cache_path "/tmp/chef"
cookbook_path "/tmp/chef/cookbooks"
role_path "/tmp/chef/roles"
log_level :info
EOF

echo "Script complete" >> $logfile