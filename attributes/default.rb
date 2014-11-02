default_unless[:redmine]         = {}
default[:redmine][:user]         = 'redmine'
default[:redmine][:home]         = '/home/redmine'
default[:redmine][:host]         = 'redmine.example.com'
default[:redmine][:version]      = '2.4.3'
default[:redmine][:ruby_version] = '1.9.3-p484'
default[:redmine][:create_db]    = true
default[:redmine][:ssl_data_bag_name] = nil
default[:redmine][:ssl_cert_dir] = "#{node[:nginx][:dir]}/ssl"
default[:redmine][:ssl_port]     = 443

default_unless[:redmine][:db]     = {}
default[:redmine][:db][:type]     = 'sqlite'
default[:redmine][:db][:hostname] = 'localhost'
default[:redmine][:db][:dbname]   = 'redmine'
default[:redmine][:db][:username] = 'redmine'
default[:redmine][:db][:password] = 'redmine'
