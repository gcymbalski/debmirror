#
# Cookbook Name:: debmirror
# Recipe:: default 
#
# Copyright 2012, Chris McClimans
# Copyright 2013, Greg Cymbalski, maybe, whatever


root=node['debmirror']['root']

include_recipe 'apache2'

directory '/root/.gnupg' do
  mode 0700
end

web_app "local_ubuntu_mirror" do
  server_name node['ipaddress'] #node['hostname']
  server_aliases [node['fqdn'], "localhost"]
  docroot "#{root}"
  template 'local_ubuntu_mirror.conf.erb'
end

# might be interesting to wrap this in an lwrp of some sort
execute "gpg --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --export |\
         gpg --no-default-keyring --keyring trustedkeys.gpg --import" do
  not_if "gpg --no-default-keyring --keyring trustedkeys.gpg --list-keys 79164387"
end

# install/bootstrap may not need i386 really... just make an empty Release file?
debmirror "#{root}/ubuntu" do
  host node['debmirror']['hostname']
  method 'rsync'
  dists 'precise,precise-updates' #,lucid,lucid-updates'
  arch 'amd64' #,i386'
  source false
  progress true
  retries 10000
end

debmirror "#{root}/ubuntu-security" do
  host node['debmirror']['hostname']
  method 'rsync'
  dists 'precise-security' # ,lucid-security'
  arch 'amd64' #,i386'
  source false
  progress true
  retries 10000
end

