$vpc_mask    = '10.90.0.0'
$zone_a_mask = '10.90.10.0'
$zone_b_mask = '10.90.20.0'
$zone_c_mask = '10.90.30.0'
$created_by  = 'chrisbarker'
$project     = 'awsdemo'
$department  = 'tse'

$regions = ['us-west-2','us-east-1','eu-west-1','ap-southeast-1','ap-southeast-2']

$regions.each |String $region| {
  awsenv::vpc { "${department}-${region}":
    region      => $region,
    department  => $department,
    vpc_mask    => $vpc_mask,
    zone_a_mask => $zone_a_mask,
    zone_b_mask => $zone_b_mask,
    zone_c_mask => $zone_c_mask,
    created_by  => $created_by,
  }
}
