# Define a mon
#
define ceph::conf::mon_config (
  $mon_addr = $name,
  $mon_port = 6789,
) {

  ceph_config {
    "mon.${name}/host":      value => $name;
    "mon.${name}/mon addr":  value => "${mon_addr}:${mon_port}";
  }
}
