## Define ceph::osd::pool
define ceph::osd::pool (
    $num_pgs,
) {
  exec { "add_ceph_pool_${name}":
    command   => "ceph osd pool create $name $num_pgs",
    unless    => "ceph osd lspools | grep \"\\<[0-9][0-9]* *$name\\>\""
  }
}
