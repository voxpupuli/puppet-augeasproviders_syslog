[![Build Status](https://travis-ci.org/hercules-team/augeasproviders_syslog.svg?branch=master)](https://travis-ci.org/hercules-team/augeasproviders_syslog)
[![Coverage Status](https://img.shields.io/coveralls/hercules-team/augeasproviders_syslog.svg)](https://coveralls.io/r/hercules-team/augeasproviders_syslog)


# syslog: type/provider for syslog files for Puppet

This module provides a new type/provider for Puppet to read and modify syslog
config files using the Augeas configuration library.

The advantage of using Augeas over the default Puppet `parsedfile`
implementations is that Augeas will go to great lengths to preserve file
formatting and comments, while also failing safely when needed.

This provider will hide *all* of the Augeas commands etc., you don't need to
know anything about Augeas to make use of it.

## Requirements

Ensure both Augeas and ruby-augeas 0.3.0+ bindings are installed and working as
normal.

See [Puppet/Augeas pre-requisites](http://docs.puppetlabs.com/guides/augeas.html#pre-requisites).

## Installing

On Puppet 2.7.14+, the module can be installed easily ([documentation](http://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html)):

    puppet module install herculesteam/augeasproviders_syslog

You may see an error similar to this on Puppet 2.x ([#13858](http://projects.puppetlabs.com/issues/13858)):

    Error 400 on SERVER: Puppet::Parser::AST::Resource failed with error ArgumentError: Invalid resource type `syslog` at ...

Ensure the module is present in your puppetmaster's own environment (it doesn't
have to use it) and that the master has pluginsync enabled.  Run the agent on
the puppetmaster to cause the custom types to be synced to its local libdir
(`puppet master --configprint libdir`) and then restart the puppetmaster so it
loads them.

## Compatibility

### Puppet versions

Minimum of Puppet 2.7.

### Augeas versions

Augeas Versions           | 0.10.0  | 1.0.0   | 1.1.0   | 1.2.0   |
:-------------------------|:-------:|:-------:|:-------:|:-------:|
**PROVIDERS**             |
syslog (augeas)           | **yes** | **yes** | **yes** | **yes** |
syslog (rsyslog)          | no      | **yes** | **yes** | **yes** |

## Documentation and examples

Type documentation can be generated with `puppet doc -r type` or viewed on the
[Puppet Forge page](http://forge.puppetlabs.com/herculesteam/augeasproviders_syslog).

A `syslog` provider handles basic syslog configs, while an `rsyslog` provider
handles the extended rsyslog config (this requires Augeas 1.0.0).

### manage entry

    syslog { "my test":
      ensure      => present,
      facility    => "local2",
      level       => "*",
      action_type => "file",
      action      => "/var/log/test.log",
    }

### manage entry with no file sync

    syslog { "cron.*":
      ensure      => present,
      facility    => "cron",
      level       => "*",
      action_type => "file",
      action      => "/var/log/cron",
      no_sync     => true,
    }

### manage remote hostname entry

    syslog { "my test":
      ensure      => present,
      facility    => "local2",
      level       => "*",
      action_type => "hostname",
      action      => "centralserver",
    }

### manage remote hostname entry with port and protocol

    syslog { "my test":
      ensure          => present,
      facility        => "local2",
      level           => "*",
      action_type     => "hostname",
      action_port     => "514",
      action_protocol => "tcp",
      action          => "centralserver",
    }

### manage user destination entry

    syslog { "my test":
      ensure      => present,
      facility    => "local2",
      level       => "*",
      action_type => "user",
      action      => "root",
    }

### manage program entry

    syslog { "my test":
      ensure      => present,
      facility    => "local2",
      level       => "*",
      action_type => "program",
      action      => "/usr/bin/foo",
    }

### delete entry

    syslog { "mail.*":
      ensure      => absent,
      facility    => "mail",
      level       => "*",
      action_type => "file",
      action      => "/var/log/maillog",
    }

### manage entry in rsyslog

    syslog { "my test":
      ensure      => present,
      facility    => "local2",
      level       => "*",
      action_type => "file",
      action      => "/var/log/test.log",
      provider    => "rsyslog",
    }

### manage entry in another syslog location

    syslog { "my test":
      ensure      => present,
      facility    => "local2",
      level       => "*",
      action_type => "file",
      action      => "/var/log/test.log",
      target      => "/etc/mysyslog.conf",
    }

## Issues

Please file any issues or suggestions [on GitHub](https://github.com/hercules-team/augeasproviders_syslog/issues).
