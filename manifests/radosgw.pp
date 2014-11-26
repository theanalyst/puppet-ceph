# Install and configure ceph radosgw
#
# == Parameters
# [*package_ensure*] The ensure state for the ceph package.
#   Optional. Defaults to present.
#
# == Dependencies
#
# none
#
# == Authors
#
#  Harish Kumar <hkumar@d4devops.org>
#
# TODO:
# Ceph patched packages for apache and fastcgi is there in ceph repos. Those
# repos to be added in the module itself.
# For some communication, keystone use signed messages which need keystone
# certificate to be added in ceph radosgw and added as nssdb format. This is to
# be done. Due to this, radosgw will not get updates on revoked tokens, also
# there will be few errors printed during restart of radosgw. This will be added
# as soon as the basic stuffs working.
#
#
class ceph::radosgw (
  $keystone_url,
  $keystone_admin_token,
  $mon_key,
  $keystone_accepted_roles      = '_member_, admin, swiftoperator',
  $keystone_token_cache_size    = 500,
  $keystone_revocation_interval = 600,
  $nss_db_path                  = '/var/lib/ceph/nss',
  $package_ensure               = 'present',
  $configure_apache             = true,
  $bind_address                 = '0.0.0.0',
  $fastcgi_ext_script           = '/var/www/s3gw.fcgi',
  $socket                       = '/var/run/ceph/radosgw.sock',
  $listen_ssl                   = false,
  $radosgw_cert_file            = undef,
  $radosgw_key_file             = undef,
  $radosgw_ca_file              = undef,
  $logfile                      = '/var/log/ceph/radosgw',
  $keyring                      = '/etc/ceph/keyring',
  $radosgw_keyring              = undef,
  $region                       = 'RegionOne',
  $radosgw_id                   = 'radosgw.gateway',
  $gw_serveradmin_email         = 'root@localhost',
  $gw_server_name               = 'localhost',
) {

  if ! $radosgw_keyring {
    $radosgw_keyring_orig = "/etc/ceph/keyring.${radosgw_id}"
  } else {
    $radosgw_keyring_orig = $radosgw_keyring
  }

  ##
  # refreshing the service on changing the configurations,
  # Ideally we should have ceph_config type to configure lot of this.
  ##

  Ceph::Auth[$radosgw_id] ~> Service['radosgw']
  Concat['/etc/ceph/ceph.conf'] ~> Service['radosgw']

  ceph::conf::radosgw { $name:
    keyring                      => $radosgw_keyring_orig,
    socket                       => $socket,
    logfile                      => $logfile,
    keystone_url                 => $keystone_url,
    keystone_admin_token         => $keystone_admin_token,
    keystone_accepted_roles      => $keystone_accepted_roles,
    keystone_token_cache_size    => $keystone_token_cache_size,
    keystone_revocation_interval => $keystone_revocation_interval,
    nss_db_path                  => $nss_db_path,
  }

  package { 'radosgw':
    ensure => $package_ensure
  }

  if $configure_apache {
    class { 'ceph::radosgw::apache':
      bind_address       => $bind_address,
      listen_ssl         => $listen_ssl,
      radosgw_cert_file  => $radosgw_cert_file,
      radosgw_key_file   => $radosgw_key_file,
      radosgw_ca_file    => $radosgw_ca_file,
      fastcgi_ext_script => $fastcgi_ext_script,
      fastcgi_ext_socket => $socket,
      serveradmin_email  => $gw_serveradmin_email,
      server_name        => $gw_server_name,
    }
  }

  ##
  # Add cephx entry for radosgw.
  ##

  ceph::auth {$radosgw_id:
    mon_key      => $mon_key,
    client       => $radosgw_id,
    keyring_path => $radosgw_keyring_orig,
    cap          => "mon 'allow rw' osd 'allow rwx'",
  }

  ##
  # Create radosgw data directory
  ##

  file {"/var/lib/ceph/radosgw/${radosgw_id}":
    ensure => 'directory',
  }

  service { 'radosgw':
    ensure     => 'running',
    enable     => true,
    provider   => 'init',
    hasstatus  => true,
    hasrestart => true,
    require    => [Ceph::Conf::Radosgw[$name],
                    File["/var/lib/ceph/radosgw/${radosgw_id}"]],
  }

}
