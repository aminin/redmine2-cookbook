require 'spec_helper'

describe iptables do
  it { should have_rule('-A FWR -p tcp -m tcp --dport 80 -j ACCEPT') }
  it { should have_rule('-A FWR -p tcp -m tcp --dport 443 -j ACCEPT') }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

describe port(443) do
  it { should be_listening.with('tcp') }
end

describe process('nginx') do
  it { should be_running }
end

describe service('nginx') do
  it { should be_enabled }
end

