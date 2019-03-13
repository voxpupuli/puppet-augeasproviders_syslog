# Manages filters in rsyslog.conf file
#
# Copyright (c) 2019 Raphaël Pinson
# Licensed under the Apache License, Version 2.0

Puppet::Type.newtype(:rsyslog_filter) do
  @doc = "Manages filters in rsyslog.conf."

  ensurable

  newparam(:name) do
    desc "The name of the resource."
    isnamevar
  end

  newparam(:property) do
    desc "The filter property."
  end

  newparam(:operation) do
    desc "The filter operation."
  end

  newparam(:value) do
    desc "The filter value."
  end

  newparam(:action_type) do
    desc "The type of action: file, hostname, user or program."
  end

  newparam(:action_protocol) do
    desc "When action is hostname, the optional protocol."
    newvalues :udp, :tcp, :'@', :'@@'

    munge do |value|
      case value
      when :udp, 'udp', :'@', '@'
        '@'
      when :tcp, 'tcp', :'@@', '@@'
        '@@'
      end
    end
  end

  newparam(:action_port) do
    desc "When action is hostname, the optional port."
  end

  newparam(:action) do
    desc "The action for the entry."
  end

  newparam(:target) do
    desc "The file in which to store the settings, defaults to
      `/etc/rsyslog.conf`."
  end

  newparam(:lens) do
    desc "The augeas lens used to parse the file"
  end

  autorequire(:file) do
    self[:target]
  end
end
