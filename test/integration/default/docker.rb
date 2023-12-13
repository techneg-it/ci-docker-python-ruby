# frozen_string_literal: true

describe file('/usr/bin/docker') do
  it { should exist }
end

describe command('docker --version') do
  its('exit_status') { should eq 0 }
end
