# Define a mds
#
define ceph::conf::clients (
  $keyring = "/etc/ceph/keyring.$name",
) {

  ceph_config {
      "client.${name}/keyring":      value => $keyring
  }

}
