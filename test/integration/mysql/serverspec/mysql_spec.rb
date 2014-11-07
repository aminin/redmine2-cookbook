require 'spec_helper'

describe process('mysqld') do
  it { should be_running }
end

describe command("mysql -u redmine -predmine -e 'show databases;'") do
  its(:exit_status) { should eq 0 }
end

