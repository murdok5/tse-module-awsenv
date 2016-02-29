# class to instantiate 6 agent systems to work us our just deployed master
# agents inherit settings based on the masters facts, so we just assume you want
# all nodes in the same AVZ, etc.
class awsenv::nodes {
  $image_ids            = lookup('awsenv::image_ids')
  $department           = $::ec2_tags['department']
  $project              = $::ec2_tags['project']
  $created_by           = $::ec2_tags['created_by']
  $region               = $::ec2_region
  $agents_sg_name       = "${department}-${region}-agents"
  $crossconnect_sq_name = "${department}-${region}-crossconnect"
  $agent_subnet         = "${department}-${region}-avza"

  $public_key = split($::ec2_metadata['public-keys']['0']['openssh-key'], ' ')
  $key_name = $public_key[2]

  # we create the standards for all nodes first
  Awsenv::Nodes::Agent {
    pp_department   => $::ec2_tags['department'],
    pp_project      => $::ec2_tags['project'],
    pp_created_by   => $::ec2_tags['created_by'],
    key_name        => $key_name,
    image_ids       => $image_ids,
    security_groups => [
      $agents_sg_name,
      $crossconnect_sq_name],
    subnet          => $agent_subnet,
  }

  awsenv::nodes::agent { ['redhat7-01','redhat7-02']:
    pp_role => 'webserver',
    platform_name => 'redhat7'
  }

  awsenv::nodes::agent { ['windows2012-01','windows2012-02']:
    pp_role => 'webserver',
    platform_name => 'windows2012'
  }

}
