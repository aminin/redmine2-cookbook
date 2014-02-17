#
# Cookbook Name:: redmine2
# Recipe:: sqlite
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

include_recipe 'sqlite::default'

file "#{node['redmine']['home']}/redmine-#{node[:redmine][:version]}/db/production.db" do
  owner node[:redmine][:user]
  group node[:redmine][:user]
  mode '0644'
end
