# Define a osd
#
define ceph::conf::osd (
  $device,
  $journal_device = undef,
  $journal_type = 'filesystem',
  $cluster_addr = undef,
  $public_addr  = undef,
) {

  ceph_config {
    "osd.${name}/host":      value => $::hostname, tag => "osd_config_${name}";
    "osd.${name}/devs":      value => $device, tag => "osd_config_${name}";
  }

  if $osd_journal_type == 'first_partition' {
    if ! $journal_device {
      fail("journal_device is required when osd_journal_type is first_partition")
    }
    ceph_config {
      "osd.${name}/osd journal":    value => $journal_device, tag => "osd_config_${name}"
    }
  }

  if $cluster_addr {
    ceph_config {
      "osd.${name}/cluster addr": value => $cluster_addr, tag => "osd_config_${name}"
    }
  }

  if $public_addr {
    ceph_config {
      "osd.${name}/public addr": value => $public_addr, tag => "osd_config_${name}";
    }
  }

}
