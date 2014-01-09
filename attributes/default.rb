default[:rbenv][:install_prefix] = "/usr/local"
default[:rbenv][:root_path]      = "#{node[:rbenv][:install_prefix]}/rbenv"
default[:rbenv][:rubies]         = []
default[:rbenv][:gems]           = Hash.new
