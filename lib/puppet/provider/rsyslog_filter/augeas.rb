# Alternative Augeas-based providers for Puppet
#
# Copyright (c) 2019 Raphaël Pinson
# Licensed under the Apache License, Version 2.0

raise('Missing augeasproviders_core dependency') if Puppet::Type.type(:augeasprovider).nil?

Puppet::Type.type(:rsyslog_filter).provide(:augeas, parent: Puppet::Type.type(:augeasprovider).provider(:default)) do
  desc 'Uses Augeas API to update an rsyslog.conf filter entry'

  default_file { '/etc/rsyslog.conf' }

  lens do |resource|
    if resource and resource[:lens]
      resource[:lens]
    else
      'Rsyslog.lns'
    end
  end

  confine feature: :augeas

  resource_path do |resource|
    property = resource[:property]
    operation = resource[:operation]
    value = resource[:value]
    action_type = resource[:action_type]
    action = resource[:action]
    "$target/filter[property='#{property}' and operation='#{operation}' and value='#{value}' and action/#{action_type}='#{action}']"
  end

  def protocol_supported
    return @protocol_supported unless @protocol_supported.nil?

    @protocol_supported = if Puppet::Util::Package.versioncmp(aug_version, '1.2.0') >= 0
                            :stock
                          elsif parsed_as?("*.* @syslog.far.away:123\n", 'entry/action/protocol')
                            :stock
                          elsif parsed_as?("*.* @@syslog.far.away:123\n", 'entry/action/protocol')
                            :el7
                          else
                            false
                          end
  end

  def self.instances
    augopen do |aug|
      resources = []

      aug.match('$target/filter').each do |apath|
        property = aug.get("#{apath}/property")
        operation = aug.get("#{apath}/operation")
        value = aug.get("#{apath}/value")
        action_type = path_label(aug, "#{apath}/action/*[label() != 'protocol' and label() != 'port']")
        action_port = aug.get("#{apath}/action/port")
        action_protocol = aug.get("#{apath}/action/protocol")
        action = aug.get("#{apath}/action/#{action_type}")
        name = "#{property} #{operation} #{value}"
        name += action_protocol if action_type == 'hostname'
        name += "#{action}"
        entry = { ensure: :present, name: name,
                  property: property, operation: operation, value: value,
                  action_type: action_type,
                  action_port: action_port,
                  action_protocol: action_protocol,
                  action: action }
        resources << new(entry)
      end

      resources
    end
  end

  def create
    property = resource[:property]
    operation = resource[:operation]
    value = resource[:value]
    action_type = resource[:action_type]
    action_port = resource[:action_port]
    action_protocol = resource[:action_protocol]
    action = resource[:action]

    augopen! do |aug|
      # TODO: make it case-insensitive
      aug.defnode('resource', resource_path, nil)
      aug.set('$resource/property', property)
      aug.set('$resource/operation', operation)
      aug.set('$resource/value', value)
      if action_protocol
        case protocol_supported
        when :stock
          aug.set('$resource/action/protocol', action_protocol)
        when :el7
          aug.set('$resource/action/protocol', action_protocol) if action_protocol == '@@'
        else
          raise(Puppet::Error, 'Protocol is not supported in this lens')
        end
      end
      aug.set("$resource/action/#{action_type}", action)
      aug.set('$resource/action/port', action_port) if action_port
    end
  end
end
