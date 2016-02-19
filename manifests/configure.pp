# this is a configure class, meant to ensure that the host in question has
# the needed modules in place for the aws commands
class awsenv::configure {

  package {['aws-sdk-core','retries']:
    ensure   => latest,
    provider => 'puppet_gem',
  }
}
