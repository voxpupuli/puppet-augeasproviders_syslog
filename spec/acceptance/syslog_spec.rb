# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'syslog and rsyslog_filter' do
  before(:all) do
    shell("printf '# test file\\nmail.* -/var/log/mail.log\\n' > /tmp/rsyslog_test.conf")
  end

  context 'with ensure => present' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          syslog { 'local2.* /var/log/test.log':
            ensure      => present,
            facility    => 'local2',
            level       => '*',
            action_type => 'file',
            action      => '/var/log/test.log',
            target      => '/tmp/rsyslog_test.conf',
            provider    => 'rsyslog',
          }
          syslog { 'local3.* @@logs.example.com:514':
            ensure          => present,
            facility        => 'local3',
            level           => '*',
            action_type     => 'hostname',
            action          => 'logs.example.com',
            action_port     => '514',
            action_protocol => 'tcp',
            target          => '/tmp/rsyslog_test.conf',
            provider        => 'rsyslog',
          }
          rsyslog_filter { 'iptables':
            ensure      => present,
            property    => 'msg',
            operation   => 'contains',
            value       => 'IPTables-Dropped: ',
            action_type => 'file',
            action      => '/var/log/iptables.log',
            target      => '/tmp/rsyslog_test.conf',
          }
        PUPPET
      end
    end

    describe file('/tmp/rsyslog_test.conf') do
      its(:content) { is_expected.to match(%r{^mail\.\*\s+-/var/log/mail\.log$}) }
      its(:content) { is_expected.to match(%r{^local2\.\*\s+/var/log/test\.log$}) }
      its(:content) { is_expected.to match(%r{^local3\.\*\s+@@logs\.example\.com:514$}) }
      its(:content) { is_expected.to match(%r{^:msg,\s*contains,\s*"IPTables-Dropped: "\s+/var/log/iptables\.log$}) }
    end
  end

  context 'with ensure => absent' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          syslog { 'mail.* /var/log/mail.log':
            ensure      => absent,
            facility    => 'mail',
            level       => '*',
            action_type => 'file',
            action      => '/var/log/mail.log',
            target      => '/tmp/rsyslog_test.conf',
            provider    => 'rsyslog',
          }
        PUPPET
      end
    end

    describe file('/tmp/rsyslog_test.conf') do
      its(:content) { is_expected.not_to match(%r{mail\.log}) }
      its(:content) { is_expected.to match(%r{^local2\.\*\s+/var/log/test\.log$}) }
    end
  end
end
