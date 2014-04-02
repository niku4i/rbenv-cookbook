#
# Cookbook Name:: rbenv
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

def with_home_for_user(username, &block)

  time = Time.now.to_i

  ruby_block "set HOME for #{username} at #{time}" do
    block do
      ENV['OLD_HOME'] = ENV['HOME']
      ENV['HOME'] = begin
        require 'etc'
        Etc.getpwnam(username).dir
      rescue ArgumentError # user not found
        "/home/#{username}"
      end
    end
  end

  yield

  ruby_block "unset HOME for #{username} #{time}" do
    block do
      ENV['HOME'] = ENV['OLD_HOME']
    end
  end
end

include_recipe "yum-epel"

package "git"

git node[:rbenv][:root_path] do
  user node[:rbenv][:user]
  group node[:rbenv][:group]
  repository "https://github.com/sstephenson/rbenv.git"
  reference "master"
  action :sync
end

%w{shims versions plugins}.each do |dir|
  directory ::File.join(node[:rbenv][:root_path], dir) do
    owner node[:rbenv][:user]
    group node[:rbenv][:group]
    action :create 
  end 
end

git "#{node[:rbenv][:root_path]}/plugins/ruby-build" do  
  user node[:rbenv][:user]
  group node[:rbenv][:group]
  repository "https://github.com/sstephenson/ruby-build.git"
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

with_home_for_user(node[:rbenv][:user]) do

  Array(node['rbenv']['rubies']).each do |ruby|
    execute "rbenv install #{ruby}" do
      user node[:rbenv][:user]
      group node[:rbenv][:group]
      not_if { ::File.exists?("#{node[:rbenv][:root_path]}/versions/#{ruby}") }
      command "source /etc/profile.d/rbenv.sh; rbenv install #{ruby}"
      action :run
    end
  end

  execute "rbenv rehash" do
    user node[:rbenv][:user]
    group node[:rbenv][:group]
    command "source /etc/profile.d/rbenv.sh; rbenv rehash"
    action :run
  end

  node['rbenv']['gems'].each do |rubie, gems|
    #Array(gems).each do |gem|
    gems.each do |gem|
      execute "gem install #{gem}" do
        user node[:rbenv][:user]
        group node[:rbenv][:group]
        command "source /etc/profile.d/rbenv.sh; RBENV_ROOT=#{node['rbenv']['root_path']} RBENV_VERSION=#{rubie} rbenv exec gem install #{gem}"
        action :run
      end
    end
  end

  execute "rbenv rehash 2" do
    user node[:rbenv][:user]
    group node[:rbenv][:group]
    command "source /etc/profile.d/rbenv.sh; rbenv rehash"
    action :run
  end

end
