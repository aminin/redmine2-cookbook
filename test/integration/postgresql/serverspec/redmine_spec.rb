require 'spec_helper'

describe user('redmine') do
  it { should exist }
end

describe user('redmine') do
  it { should have_home_directory '/home/redmine' }
end

describe command('ruby -v') do
  let(:path) { '/home/redmine/.rbenv/shims:$PATH' }
  its(:stdout) { should match(/ruby 1\.9\.3p484.*/) }
end

describe package('bundler') do
  let(:path) { '/home/redmine/.rbenv/shims:$PATH' }
  it { should be_installed.by('gem') }
end

describe file('/home/redmine/redmine-2.6.0') do
  it { should be_directory }
end

describe file('/home/redmine/redmine') do
  it { should be_linked_to '/home/redmine/redmine-2.6.0' }
end

describe process('ruby') do
  its(:args) { should match(/script\/rails s thin -p 3000/) }
end
