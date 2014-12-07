#
# Cookbook Name:: redmine2
# Recipe:: mysql
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

include_recipe 'mysql::server'
include_recipe 'mysql::client'

if [true, 'true'].include? node[:redmine][:create_db]
  include_recipe 'database::mysql'

  connection_info = {
      host:     node[:redmine][:db][:hostname],
      username: 'root',
      password: node[:mysql][:server_root_password]
  }

  mysql_database_user node[:redmine][:db][:username] do
    connection connection_info
    password   node[:redmine][:db][:password]
    action     :create
  end

  mysql_database node[:redmine][:db][:dbname] do
    connection connection_info
    owner node[:redmine][:db][:username]
    encoding 'utf8'
    action :create
  end

  mysql_database_user node[:redmine][:db][:username] do
    connection    connection_info
    database_name node[:redmine][:db][:dbname]
    host          '%'
    privileges    [:all]
    action        :grant
  end
end
