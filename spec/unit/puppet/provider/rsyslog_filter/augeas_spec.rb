#!/usr/bin/env rspec

require 'spec_helper'
provider_class = Puppet::Type.type(:rsyslog_filter).provider(:augeas)

describe provider_class do
  let(:protocol_supported) { subject.protocol_supported }

  context "with empty file" do
    let(:tmptarget) { aug_fixture("empty") }
    let(:target) { tmptarget.path }

    it "should create new entry with file" do
      FileTest.stubs(:exist?).returns false
      FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true
      FileTest.stubs(:exist?).returns false
      FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true

      apply!(Puppet::Type.type(:rsyslog_filter).new(
        :name        => "my test",
        :property    => "msg",
        :operation   => "contains",
        :value       => "IPTables-Dropped: ",
        :action_type => "file",
        :action      => "/var/log/iptables.log",
        :target      => target,
        :provider    => "augeas",
        :ensure      => "present",
      ))

      aug_open(target, "Rsyslog.lns") do |aug|
        expect(aug.match("filter").size).to eq(1)
        expect(aug.get("filter/value")).to eq("IPTables-Dropped: ")
        expect(aug.get("filter/action/file")).to eq("/var/log/iptables.log")
      end
    end

    it "should create new entry with protocol/hostname/port" do
      FileTest.stubs(:exist?).returns false
      FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true
      FileTest.stubs(:exist?).returns false
      FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true

      apply!(Puppet::Type.type(:rsyslog_filter).new(
        :name            => "my test",
        :property        => "msg",
        :operation       => "contains",
        :value           => "IPTables-Dropped: ",
        :action_type     => "hostname",
        :action          => "logs.local",
        :action_protocol => "@@",
        :action_port     => "514",
        :target          => target,
        :provider        => "augeas",
        :ensure          => "present",
      ))

      aug_open(target, "Rsyslog.lns") do |aug|
        expect(aug.match("filter").size).to eq(1)
        expect(aug.get("filter/value")).to eq("IPTables-Dropped: ")
        expect(aug.get("filter/action/hostname")).to eq("logs.local")
      end
    end
  end

  context "with full file" do
    let(:tmptarget) { aug_fixture("full") }
    let(:target) { tmptarget.path }

    it "should list instances" do
      FileTest.stubs(:exist?).returns false
      FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true
      FileTest.stubs(:exist?).returns false
      FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true

      provider_class.stubs(:target).returns(target)
      inst = provider_class.instances.map { |p|
        {
          :name            => p.get(:name),
          :ensure          => p.get(:ensure),
          :property        => p.get(:property),
          :operation       => p.get(:operation),
          :value           => p.get(:value),
          :action_type     => p.get(:action_type),
          :action_protocol => p.get(:action_protocol),
          :action_port     => p.get(:action_port),
          :action          => p.get(:action),
        }
      }

      expect(inst.size).to eq(1)
      expect(inst[0]).to eq({
          :ensure=>:present,
          :name=>"msg contains sshd@@logserver.dev",
          :property=>"msg",
          :operation=>"contains",
          :value=>"sshd",
          :action_type=>"hostname",
          :action_protocol=>"@@",
          :action_port=>"514",
          :action=>"logserver.dev",
      })
    end

    describe "when creating settings" do
      it "should create a simple new entry" do
        FileTest.stubs(:exist?).returns false
        FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true
        FileTest.stubs(:exist?).returns false
        FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true

        apply!(Puppet::Type.type(:rsyslog_filter).new(
          :name        => "my test",
          :property    => "msg",
          :operation   => "contains",
          :value       => "IPTables-Dropped: ",
          :action_type => "file",
          :action      => "/var/log/iptables.log",
          :target      => target,
          :provider    => "augeas",
          :ensure      => "present",
        ))

        aug_open(target, "Rsyslog.lns") do |aug|
          expect(aug.get("filter/action/file")).to eq("/var/log/iptables.log")
        end
      end
    end

    describe "when modifying settings" do
      it "should use file" do
        FileTest.stubs(:exist?).returns false
        FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true
        FileTest.stubs(:exist?).returns false
        FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true

        apply!(Puppet::Type.type(:rsyslog_filter).new(
          :name        => "ssh",
          :property    => "msg",
          :operation   => "contains",
          :value       => "sshd",
          :action_type => "file",
          :action      => "/var/log/sshd.log",
          :target      => target,
          :provider    => "augeas",
          :ensure      => "present",
        ))

        aug_open(target, "Rsyslog.lns") do |aug|
          expect(aug.get("filter/action/file")).to eq("/var/log/sshd.log")
        end
      end
    end

    describe "when removing settings" do
      it "should remove the entry" do
        FileTest.stubs(:exist?).returns false
        FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true
        FileTest.stubs(:exist?).returns false
        FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true

        apply!(Puppet::Type.type(:rsyslog_filter).new(
          :name        => "ssh",
          :property    => "msg",
          :operation   => "contains",
          :value       => "sshd",
          :action_type => "file",
          :action      => "/var/log/sshd.log",
          :target      => target,
          :provider    => "augeas",
          :ensure      => "absent",
        ))

        aug_open(target, "Syslog.lns") do |aug|
          expect(aug.match("entry[selector/facility='mail' and level='*']").size).to eq(0)
        end
      end
    end
  end

  context "with broken file" do
    let(:tmptarget) { aug_fixture("broken") }
    let(:target) { tmptarget.path }

    it "should fail to load" do
      FileTest.stubs(:exist?).returns false
      FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true
      FileTest.stubs(:exist?).returns false
      FileTest.stubs(:exist?).with('/etc/rsyslog.conf').returns true

      txn = apply(Puppet::Type.type(:rsyslog_filter).new(
        :name        => "ssh",
        :property    => "msg",
        :operation   => "contains",
        :value       => "sshd",
        :action_type => "file",
        :action      => "/var/log/sshd.log",
        :target      => target,
        :provider    => "augeas",
        :ensure      => "absent",
      ))

      expect(txn.any_failed?).not_to eq(nil)
      expect(@logs.first.level).to eq(:err)
      expect(@logs.first.message.include?(target)).to eq(true)
    end
  end
end
