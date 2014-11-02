#
# Cookbook Name:: redmine2
# Recipe:: default
#
# Copyright 2014, Anton Minin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Create a redmine OS account with the users cookbook
user node[:redmine][:user] do
  comment 'Redmine user'
  shell '/bin/bash'
  home node[:redmine][:home]
  action :create
end

# Create home directory
directory node[:redmine][:home] do
  owner node[:redmine][:user]
  group node[:redmine][:user]
  mode '0755'
end

# Install ruby with rbenv
node.default['rbenv']['user_installs'] = [
    {
        user: node[:redmine][:user],
        rubies: [node[:redmine][:ruby_version]],
        global: node[:redmine][:ruby_version],
        gems: {
            node[:redmine][:ruby_version] => [
                { name: 'bundler' },
                { name: 'rake' }
            ]
        }
    }
]

include_recipe 'ruby_build'
include_recipe 'rbenv::user'

# Download archive with source code
bash 'install_redmine' do
  cwd node[:redmine][:home]
  user node[:redmine][:user]
  code <<-EOH
    wget http://www.redmine.org/releases/redmine-#{node[:redmine][:version]}.tar.gz;
    tar -xzf redmine-#{node[:redmine][:version]}.tar.gz
  EOH
  not_if { ::File.exists?("#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/Rakefile") }
end

link "#{node[:redmine][:home]}/redmine" do
  to "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
end

# Create database
case node[:redmine][:db][:type]
  when 'sqlite'
    include_recipe 'redmine2::sqlite'
  when 'mysql'
    include_recipe 'redmine2::mysql'
  when 'postgresql'
    include_recipe 'redmine2::postgresql'
end

template "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/config/database.yml" do
  source 'database.yml.erb'
  owner node[:redmine][:user]
  variables database_server: node[:redmine][:db][:hostname]
  mode '0664'
end

# Configure email
template "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/config/configuration.yml" do
  source 'configuration.yml.erb'
  owner node[:redmine][:user]
  variables {}
  mode '0664'
end

# Configure environment.rb
template "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/config/environment.rb" do
  source 'environment.rb.erb'
  owner node[:redmine][:user]
  variables {}
  mode '0644'
end

# Configure custom gems e.g. thin
template "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/Gemfile.local" do
  source 'Gemfile.local.erb'
  owner node[:redmine][:user]
  variables {}
  mode '0664'
end

bundle_command = "#{node[:redmine][:home]}/.rbenv/shims/bundle"
rake_command = "#{node[:redmine][:home]}/.rbenv/shims/rake"
bundle_install_command = case node[:redmine][:db][:type]
  when 'sqlite'
    "#{bundle_command} install --without development test mysql postgresql rmagick"
  when 'mysql'
    "#{bundle_command} install --without development test postgresql sqlite rmagick"
  when 'postgresql'
    "#{bundle_command} install --without development test mysql sqlite rmagick"
end

execute bundle_install_command do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  not_if { ::File.exists?("#{node[:redmine][:home]}redmine-#{node[:redmine][:version]}/db/schema.rb") }
end

execute "RAILS_ENV='production' #{rake_command} db:migrate" do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  not_if { ::File.exists?("#{node[:redmine][:home]}redmine-#{node[:redmine][:version]}/db/schema.rb") }
end

execute "RAILS_ENV='production' #{rake_command} generate_secret_token" do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  not_if { ::File.exists?("#{node[:redmine][:home]}redmine-#{node[:redmine][:version]}/config/initializers/secret_token.rb") }
end

include_recipe 'runit'

runit_service 'redmine' do
  log_template_name 'redmine'
  run_template_name 'redmine'
  options(home_path:   node[:redmine][:home],
          app_path:    "#{node[:redmine][:home]}/redmine",
          target_user: node[:redmine][:user],
          rbenv_shims: "#{node[:redmine][:home]}/.rbenv/shims",
          target_env:  'production')
end

if ! node[:redmine][:ssl_data_bag_name].nil? then
  certificate_manage "#{node[:redmine][:ssl_data_bag_name]}" do
    cert_path node[:redmine][:ssl_cert_dir]
    owner node[:nginx][:user]
    group node[:nginx][:user]
    nginx_cert true
    create_subfolders true
  end
end

include_recipe 'nginx'

template "#{node[:nginx][:dir]}/sites-available/redmine" do
  source 'nginx-redmine.erb'
  mode 0777
  owner node[:nginx][:user]
  group node[:nginx][:user]
  variables(
    app_path: "#{node[:redmine][:home]}/redmine",
    server_name: node[:redmine][:host],
    ssl_port: node[:redmine][:ssl_port],
    ssl_cert: "#{node[:redmine][:ssl_cert_dir]}/certs/#{node.fqdn}.pem",
    ssl_key: "#{node[:redmine][:ssl_cert_dir]}/private/#{node.fqdn}.key"
  )
end

nginx_site 'redmine' do
  enable true
end

# Configure SCM e.g. Git
