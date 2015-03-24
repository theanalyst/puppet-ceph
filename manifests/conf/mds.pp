# Define a mds
#
define ceph::conf::mds (
  $mds_data
) {

  ceph_config {
      "mds.${name}/host":      value => $::hostname
  }
}
