# Define a mds
#
define ceph::conf::mds {

  ceph_config {
      "mds.${name}/host":      value => $::hostname
  }
}
