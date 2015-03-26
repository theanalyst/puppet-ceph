# Define a mon
#
define ceph::conf::mon (
  $mon_addr,
  $mon_port,
) {

  ceph_config {
    "mon.${name}/host":      value => $::hostname;
    "mon.${name}/mon addr":  value => "${mon_addr}:${mon_port}";
  }
}
