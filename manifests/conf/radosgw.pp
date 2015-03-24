# Define a radosgw
#
define ceph::conf::radosgw (
  $keystone_url,
  $keystone_admin_token,
  $keystone_accepted_roles = 'Member, admin, swiftoperator',
  $keystone_token_cache_size = 500,
  $keystone_revocation_interval = 600,
  $nss_db_path = '/var/lib/ceph/nss',
  $keyring = '/etc/ceph/keyring',
  $socket = '/var/run/ceph/radosgw.sock',
  $logfile = '/var/log/ceph/radosgw.log',
) {

  ceph_config {
    'client.radosgw.gateway/host':  value => $::hostname;
    'client.radosgw.gateway/keyring':  value => $keyring;
    'client.radosgw.gateway/rgw socket path':  value => $socket;
    'client.radosgw.gateway/log file':  value => $logfile;
    'client.radosgw.gateway/rgw keystone url':  value => $keystone_url;
    'client.radosgw.gateway/rgw keystone admin token':  value => $keystone_admin_token;
    'client.radosgw.gateway/rgw keystone accepted roles':  value => $keystone_accepted_roles;
    'client.radosgw.gateway/rgw keystone token cache size':  value => $keystone_token_cache_size;
    'client.radosgw.gateway/rgw keystone revocation interval':  value => $keystone_revocation_interval;
    'client.radosgw.gateway/rgw s3 auth use keystone':  value => 'true';
  }

  if $ceph_radosgw_listen_ssl {
    ceph_config {
      'client.radosgw.gateway/nss db path': value => $nss_db_path;
    }
  }
}
