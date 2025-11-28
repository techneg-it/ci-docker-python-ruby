# frozen_string_literal: true

describe file('/usr/include/yaml.h') do
  it { should exist }
end

describe command('gcc /tmp/test_yaml.c -lyaml -o /tmp/test_yaml') do
  its('exit_status') { should eq 0 }
end

describe command('/tmp/test_yaml') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/libyaml version/) }
end
