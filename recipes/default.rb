#
# Cookbook Name:: rbenv
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "yum-epel"

package "git"

git node[:rbenv][:root_path] do
  repository "https://github.com/sstephenson/rbenv.git"
  reference "master"
  action :sync
end

%w{shims versions plugins}.each do |dir|
  directory ::File.join(node[:rbenv][:root_path], dir) do
    action :create 
  end 
end

git "#{node[:rbenv][:root_path]}/plugins/ruby-build" do  
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

Array(node['rbenv']['rubies']).each do |ruby|
  execute "rbenv install #{ruby}" do
    not_if { ::File.exists?("#{node[:rbenv][:root_path]}/versions/#{ruby}") }
    command "source /etc/profile.d/rbenv.sh; rbenv install #{ruby}"
    action :run
  end
end

execute "rbenv rehash" do
  command "source /etc/profile.d/rbenv.sh; rbenv rehash"
  action :run
end

node['rbenv']['gems'].each do |rubie, gems|
  #Array(gems).each do |gem|
  gems.each do |gem|
    execute "gem install #{gem}" do
      command "source /etc/profile.d/rbenv.sh; RBENV_ROOT=#{node['rbenv']['root_path']} RBENV_VERSION=#{rubie} rbenv exec gem install #{gem}"
      action :run
    end
  end
end

execute "rbenv rehash 2" do
  command "source /etc/profile.d/rbenv.sh; rbenv rehash"
  action :run
end
