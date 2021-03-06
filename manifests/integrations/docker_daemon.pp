# Class: datadog_agent::integrations::docker
#
# This class will install the necessary configuration for the docker integration
#
# Parameters:
#   $url:
#     The URL for docker API
#
#   $tags:
#     optional array of tags
#
#   $group:
#     optional name of docker group to add dd-agent user too
#
#
# Sample Usage:
#
#   class { 'datadog_agent::integrations::docker' :
#     url           => 'unix://var/run/docker.sock',
#   }
#
class datadog_agent::integrations::docker_daemon(
  $url = 'unix://var/run/docker.sock',
  $tags = [],
  $group = 'docker',
) inherits datadog_agent::params {
  include datadog_agent

  exec { 'dd-agent-should-be-in-docker-group':
    command => "/usr/sbin/usermod -aG ${group} ${datadog_agent::params::dd_user}",
    unless  => "/bin/cat /etc/group | grep '^${group}:' | grep -qw ${datadog_agent::params::dd_user}",
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }

  file { "${datadog_agent::params::conf_dir}/docker.yaml":
    ensure => 'absent'
  }

  file { "${datadog_agent::params::conf_dir}/docker_daemon.yaml":
    ensure  => file,
    owner   => $datadog_agent::params::dd_user,
    group   => $datadog_agent::params::dd_group,
    mode    => '0644',
    content => template('datadog_agent/agent-conf.d/docker_daemon.yaml.erb'),
    require => Package[$datadog_agent::params::package_name],
    notify  => Service[$datadog_agent::params::service_name]
  }
}
