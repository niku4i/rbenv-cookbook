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

%w{make gcc zlib-devel openssl-devel readline-devel ncurses-devel gdbm-devel db4-devel libffi-devel tk-devel libyaml-devel}.each do |pkg|
  yum_package pkg do
    action :install
  end 
end

template "rbenv.sh" do
  path "/etc/profile.d/rbenv.sh"
  owner "root"
  group "root"
  mode "0644"
  source "rbenv.sh.erb"
end

Array(node[:rbenv][:user_installs]).each do |rbenv_user|
  group  = rbenv_user[:group]
  user   = rbenv_user[:user]
  rubies = rbenv_user[:rubies]
  ruby_and_gems   = rbenv_user[:gems]
  root_path = "/home/#{rbenv_user[:user]}/.rbenv"

  group group

  user user do
    group group
  end

  git root_path do
    user user
    group group
    repository "https://github.com/sstephenson/rbenv.git"
    reference "master"
    action :sync
  end

  %w{shims versions plugins}.each do |dir|
    directory ::File.join(root_path, dir) do
      owner user
      group group
      action :create 
    end 
  end

  git "#{root_path}/plugins/ruby-build" do  
    user user
    group group
    repository "https://github.com/sstephenson/ruby-build.git"
    reference "master"
    action :sync
  end

  with_home_for_user(user) do

    Array(rubies).each do |ruby|
      execute "rbenv install #{ruby} for #{user}" do
        user user
        group group
        not_if { ::File.exists?("#{root_path}/versions/#{ruby}") }
        command "source /etc/profile.d/rbenv.sh; rbenv install #{ruby}"
        action :run
      end
    end

    execute "rbenv rehash on #{user} user" do
      user user
      group group
      command "source /etc/profile.d/rbenv.sh; rbenv rehash"
      action :run
    end

    ruby_and_gems.each do |rubie, gems|
      gems.each do |gem|
        execute "gem install #{gem} on #{user} user" do
          user user
          group group
          command "source /etc/profile.d/rbenv.sh; RBENV_ROOT=#{root_path} RBENV_VERSION=#{rubie} rbenv exec gem install #{gem}"
          action :run
        end
      end
    end

    execute "rbenv rehash 2 on #{user} user" do
      user user
      group group
      command "source /etc/profile.d/rbenv.sh; rbenv rehash"
      action :run
    end
  end

end
