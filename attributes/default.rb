default[:rbenv][:install_prefix] = "/usr/local"
default[:rbenv][:root_path]      = "#{node[:rbenv][:install_prefix]}/rbenv"
default[:rbenv][:rubies]         = []  # e.g. [ "1.9.3-p0", "jruby-1.6.5" ]
