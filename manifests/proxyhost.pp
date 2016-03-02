# this sets up a nonroot user to be assigned classes in the console to provison nodes
class awsenv::proxyhost (
  $username = 'awsprovisioner',
  $check_interval = '5',
  $region = $::ec2_region,
) {
  require awsenv::configure

  $userhome = "/home/${username}"

  user { $username:
    ensure     => present,
    managehome => true,
  }

  File{
    owner   => $username,
    group   => $username,
    mode    => 0700,
    require => User[$username]
  }

  file {[
    "${userhome}/.puppetlabs",
    "${userhome}/.puppetlabs/puppet",
    ]:
    ensure => directory,
  }
  file {'/home/awsprovisioner/.puppetlabs/puppet/puppet.conf':
    ensure => present,
  }

  file {'/home/awsprovisioner/.puppetlabs/puppet/puppetlabs_aws_configuration.ini':
    ensure => present,
  }

  ini_setting { "${username} puppet servername":
    ensure  => present,
    path    => "${userhome}/.puppetlabs/puppet/puppet.conf",
    section => 'agent',
    setting => 'server',
    value   => $::fqdn,
    require => File["${userhome}/.puppetlabs/puppet/puppet.conf"]
  }
  ini_setting { "${username} puppet certname":
    ensure  => present,
    path    => "${userhome}/.puppetlabs/puppet/puppet.conf",
    section => 'agent',
    setting => 'certname',
    value   => "${::fqdn}-awsprovisioner",
    require => File["${userhome}/.puppetlabs/puppet/puppet.conf"]
  }
  ini_setting { "${username} aws region":
    ensure  => present,
    path    => "${userhome}/.puppetlabs/puppet/puppetlabs_aws_configuration.ini",
    section => 'default',
    setting => 'region',
    value   => $region,
    require => File["${userhome}/.puppetlabs/puppet/puppetlabs_aws_configuration.ini"]
  }

  cron { 'cron.puppet.awsprovisioner':
    command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize',
    user    => $username,
    minute  => "*/${check_interval}",
    require => [
      File["${userhome}/.puppetlabs"],
      User[$username]
    ]
  }

  package { 'puppetclassify':
    ensure   => present,
    provider => puppet_gem,
  }

  Node_group {
    require => Package['puppetclassify'],
  }

  node_group { 'AWS Provisioner':
    ensure               => present,
    environment          => 'production',
    override_environment => false,
    parent               => 'All Nodes',
    rule                 => ['or', ['=', 'name', "${::fqdn}-awsprovisioner"]],
    classes              => {
      'awsenv::nodes'    => {},
    }
  }
}
