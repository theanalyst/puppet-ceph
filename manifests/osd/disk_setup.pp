# Setup disks for ceph - this would include partitioning, formatting the disks
#

define ceph::osd::disk_setup (
  $osd_journal_type  = 'filesystem',
  $osd_journal_size  = 2,
  $autogenerate      = false,
) {

  include ceph::osd

  $devname = regsubst($name, '.*/', '')

  ##
  # if $autogenerate enabled, the disk device will be loop devices which
  # has different naming convension for parttion devices.
  # e.g device name of partition 1 on /dev/sda is /dev/sda1, but
  #     device name of partition 1 on /dev/loop0 is /dev/loop0p1,
  # Below patch is to add prefix "p" to get correct partition name
  ##
  if $autogenerate {
    $part_name_prefix = "${devname}p"
    $part_prefix      = "${name}p"
  } else {
    $part_name_prefix = $devname
    $part_prefix      = $name
  }

  exec { "mktable_gpt_${devname}":
    command => "parted --script -a optimal --script ${name} mktable gpt",
    unless  => "parted --script ${name} print|grep -sq 'Partition Table: gpt'",
    require => Package['parted']
  }

  if $osd_journal_type == 'first_partition' {
    exec { "mkpart_journal_${devname}":
         command => "parted --script -a optimal -s ${name} mkpart ceph_journal 0GiB ${osd_journal_size}GiB",
         unless  => "parted --script ${name} print | egrep '^ 1.*ceph_journal$'",
         require => [Package['parted'], Exec["mktable_gpt_${devname}"]]
    }
    exec { "mkpart_${devname}":
    	command => "parted --script -a optimal -s ${name} mkpart ceph ${osd_journal_size}GiB 100%",
    	unless  => "parted --script ${name} print | egrep '^ 2.*ceph$'",
    	require => [Package['parted'], Exec["mktable_gpt_${devname}"], Exec["mkpart_journal_${devname}"]]
    }

    exec { "partprobe_${devname}":
      command => "partprobe ${name}",
      unless  => "test -b ${part_prefix}2",
      require => [Exec["mkpart_journal_${devname}"],Exec["mkpart_${devname}"]],
    }

    exec { "mkfs_${devname}":
    	command => "mkfs.xfs -f -d agcount=${::processorcount} -l \
size=1024m -n size=64k ${part_prefix}2",
      unless  => "xfs_admin -l ${part_prefix}2",
      require => [Package['xfsprogs'], Exec["partprobe_${devname}"]],
    }

    $blkid_uuid_fact         = "blkid_uuid_${part_name_prefix}2"
    $osd_id_fact             = "ceph_osd_id_${part_name_prefix}2"
    $osd_data_device_name    = "${part_prefix}2"
    $osd_journal_device_name = "${part_prefix}1"
  } elsif $osd_journal_type == 'filesystem' {

    exec { "mkpart_${devname}":
      command => "parted --script -a optimal -s ${name} mkpart ceph 0% 100%",
    	unless  => "parted --script ${name} print | egrep '^ 1.*ceph$'",
    	require => [Package['parted'], Exec["mktable_gpt_${devname}"]]
    }

    exec { "partprobe_${devname}":
      command => "partprobe ${name}",
      unless  => "test -b ${part_prefix}1",
      require => Exec["mkpart_${devname}"]
    }

    exec { "mkfs_${devname}":
      command => "mkfs.xfs -f -d agcount=${::processorcount} -l \
size=1024m -n size=64k ${part_prefix}1",
      unless  => "xfs_admin -l ${part_prefix}1",
      require => [Package['xfsprogs'], Exec["partprobe_${devname}"]],
    }

  }
}
