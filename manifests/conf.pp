# Creates the ceph configuration file
#
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*auth_type*] Auth type.
#   Optional. none or 'cephx'. Defaults to 'cephx'.
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier francois.charlier@enovance.com
#  Sébastien Han     sebastien.han@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#
class ceph::conf (
#  $fsid = '392a9e9b-f499-43d8-b784-3db9e870cbf5',
  $fsid,
  $auth_type               = 'cephx',
  $signatures_require      = undef,
  $signatures_cluster      = undef,
  $signatures_service      = undef,
  $signatures_sign_msgs    = undef,
  $pool_default_size       = 3,
  $pool_default_pg_num     = 1024,
  $pool_default_pgp_num    = 1024,
  $pool_default_min_size   = undef,
  $pool_default_crush_rule = undef,
  $journal_size_mb         = 4096,
  $cluster_network         = undef,
  $public_network          = undef,
  $mon_data                = '/var/lib/ceph/mon/mon.$id',
  $mon_init_members        = undef,
  $osd_data                = '/var/lib/ceph/osd/ceph-$id',
  $osd_journal             = undef,
  $osd_journal_type	       = 'filesystem',
  $mds_data                = '/var/lib/ceph/mds/ceph-$id',
  $mon_timecheck_interval  = undef,
) {

  include 'ceph::package'

  if $osd_journal {
    $osd_journal_real = $osd_journal
  } else {
    $osd_journal_real = "${osd_data}/journal"
  }

  Package['ceph'] -> Ceph_config<||>
  File['/etc/ceph/ceph.conf'] -> Ceph_config<||>

  file { '/etc/ceph/ceph.conf':
    owner   => 'root',
    group   => 0,
    mode    => '0664',
    require => Package['ceph'],
  }

  ceph_config {
    'global/keyring':                  value => '/etc/ceph/keyring';
    'global/fsid':                     value => $fsid;
    'global/osd pool default size':    value => $pool_default_size;
    'global/osd pool default pg num':  value => $pool_default_pg_num;
    'global/osd pool default pgp num': value => $pool_default_pgp_num;
    'mon/mon data':                    value => $mon_data;
    'osd/filestore flusher':           value => false, tag => 'osd_config';
    'osd/osd data':                    value => $osd_data, tag => 'osd_config';
    'osd/osd mkfs type':               value => 'xfs', tag => 'osd_config';
    'osd/keyring':                     value => "${osd_data}/keyring", tag => 'osd_config';
    'mds/mds data':                    value => $mds_data;
    'mds/keyring':                     value => "${mds_data}/keyring";

  }

  if $osd_journal_type == 'filesystem' {
    ceph_config {
      'osd/osd journal':      value => $osd_journal_real, tag => 'osd_config';
      'osd/osd journal size': value => $journal_size_mb, tag => 'osd_config';
    }
  }

  if $auth_type {
    ceph_config {
      'global/auth cluster required': value => $auth_type;
      'global/auth service required': value => $auth_type;
      'global/auth client required':  value => $auth_type;
    }
  }

  if $signatures_require {
    ceph_config {
      'global/cephx require signatures': value => $signatures_require
    }
  }

  if $signatures_cluster {
    ceph_config {
      'global/cephx cluster require signatures': value => $signatures_cluster
    }
  }

  if $signatures_service {
    ceph_config {
      'global/cephx service require signatures': value => $signatures_service
    }
  }

  if $signatures_sign_msgs {
    ceph_config {
      'global/cephx sign messages': value => $signatures_sign_msgs
    }
  }

  if $cluster_network {
    ceph_config {
      'global/cluster network': value => $cluster_network
    }
  }

  if $public_network {
    ceph_config {
      'global/public network':  value => $public_network;
    }
  }

  if $pool_default_min_size {
    ceph_config {
      'global/osd pool default min size': value => $pool_default_min_size
    }
  }

  if $pool_default_crush_rule {
    ceph_config {
      'global/osd pool default crush rule': value => $pool_default_crush_rule
    }
  }

  if $mon_timecheck_interval {
    ceph_config {
      'global/mon timecheck interval': value => $mon_timecheck_interval
    }
  }

  if $mon_init_members {
    ceph_config {
      'mon/mon initial members': value => $mon_init_members
    }
  }


}
