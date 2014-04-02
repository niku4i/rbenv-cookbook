default[:rbenv][:user]           = "rbenv"
default[:rbenv][:group]          = "rbenv"
default[:rbenv][:root_path]      = "/home/#{node[:rbenv][:user]}/.rbenv"
default[:rbenv][:rubies]         = []
default[:rbenv][:gems]           = Hash.new
