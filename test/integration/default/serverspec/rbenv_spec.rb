require 'spec_helper'

describe group('rbenv') do
  it { should exist }
end

describe user('rbenv') do
  it { should exist }
  it { should belong_to_group 'rbenv' }
end

%w(
  /home/rbenv/.rbenv
  /home/rbenv/.rbenv/shims
  /home/rbenv/.rbenv/versions
  /home/rbenv/.rbenv/plugins
  /home/rbenv/.rbenv/plugins/ruby-build
).each do |dir|
  describe file(dir) do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'rbenv' }
    it { should be_grouped_into 'rbenv' }
  end
end

describe file('/etc/profile.d/rbenv.sh') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

%w(make gcc zlib-devel openssl-devel readline-devel ncurses-devel gdbm-devel db4-devel libffi-devel tk-devel libyaml-devel).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe file('/home/rbenv/.rbenv/bin/rbenv') do
  it { should be_executable }
  it { should be_owned_by 'rbenv' }
  it { should be_grouped_into 'rbenv' }
end
