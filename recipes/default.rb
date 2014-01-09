#
# Cookbook Name:: rbenv-cookbook
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "yum-epel"

git "/usr/local/rbenv" do
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  action :sync
end

%w{/usr/local/rbenv/shims /usr/local/rbenv/versions /usr/local/rbenv/plugins}.each do |dir|
  directory dir do
    action :create 
  end 
end

git "/usr/local/rbenv/plugins/ruby-build" do  
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :sync
end

template "rbenv.sh" do
  path "/etc/profile.d/rbenv.sh"
  owner "root"
  group "root"
  mode "0644"
  source "rbenv.sh.erb"
end

%w{make gcc zlib-devel openssl-devel readline-devel ncurses-devel gdbm-devel db4-devel libffi-devel tk-devel libyaml-devel}.each do |pkg|
  yum_package pkg do
    action :install
  end 
end

execute "rbenv install 2.0.0-p195" do
  not_if { ::File.exists?("/usr/local/rbenv/versions/2.0.0-p195") }
  command "source /etc/profile.d/rbenv.sh; rbenv install 2.0.0-p195"
  action :run
end

execute "rbenv rehash" do
  command "source /etc/profile.d/rbenv.sh; rbenv rehash"
  action :run
end
