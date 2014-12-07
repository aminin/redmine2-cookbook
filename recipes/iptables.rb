#
# Cookbook Name:: redmine2
# Recipe:: iptables
#
include_recipe 'iptables::default'

iptables_rule "redmine_iptables" do
  variables(
    listen_port:     node[:redmine][:listen_port],
    ssl_listen_port: node[:redmine][:ssl_listen_port],
  )
end

