#
# Cookbook Name:: redmine2
# Recipe:: plugins
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

package "git-core"
package "unzip"

bundle_command = "/opt/rbenv/shims/bundle"
rake_command = "/opt/rbenv/shims/rake"
bundle_install_command = case node[:redmine][:db][:type]
  when 'sqlite'
    "#{bundle_command} install --path vendor/bundle --without development test mysql postgresql rmagick"
  when 'mysql'
    "#{bundle_command} install --path vendor/bundle --without development test postgresql sqlite rmagick"
  when 'postgresql'
    "#{bundle_command} install --path vendor/bundle --without development test mysql sqlite rmagick"
end

execute bundle_install_command do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  action :nothing
end

execute "RAILS_ENV='production' #{rake_command} redmine:plugins:migrate" do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  action :nothing
end

service "redmine" do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :nothing
end

plugins = node[:redmine][:plugins]

if ! plugins.nil? && ! plugins.empty?

  plugins.each do |plugin|

    case plugin[:type]
    when 'git' then
      rev = plugin[:revision] || 'master'
      git "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/plugins/#{plugin[:name]}" do
        user node[:redmine][:user]
        repository plugin[:source]
        revision rev
        action :sync
        notifies :run, "execute[#{bundle_install_command}]", :delayed
        notifies :run, "execute[RAILS_ENV='production' #{rake_command} redmine:plugins:migrate]", :delayed
        notifies :restart, "service[redmine]", :delayed
      end

    when 'zip' then
      zipfile = File.basename(plugin[:source])
      # FC041
      bash "Deploy #{plugin[:name]}" do
        user node[:redmine][:user]
        cwd '/tmp'
        code <<-EOF
          wget #{plugin[:source]}
          unzip #{zipfile}
          mv #{plugin[:name]} #{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/plugins/#{plugin[:name]}
          rm -rf #{zipfile}
        EOF
        notifies :run, "execute[#{bundle_install_command}]", :delayed
        notifies :run, "execute[RAILS_ENV='production' #{rake_command} redmine:plugins:migrate]", :delayed
        notifies :restart, "service[redmine]", :delayed
        not_if { ::File.exists?("#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/plugins/#{plugin[:name]}") }
      end
    end
  end
end

