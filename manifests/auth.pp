# Define ceph::auth
# To add cephx keys for various client.
#

define ceph::auth (
  $mon_key,
  $client       = $name,
  $file_owner   = 'root',
  $keyring_path = '/etc/ceph/keyring',
  $cap          = undef,
  $ceph_connect_timeout = 5,
) {

  file { $keyring_path:
    ensure => present,
    owner  => $file_owner,
    mode   => '0600',
  }

  exec { "exec_add_ceph_auth_${client}":
    command =>  "ceph-authtool ${keyring_path} \
                  --name=client.${client} --add-key \
                  $(ceph --connect-timeout $ceph_connect_timeout --name mon. --key '${mon_key}' \
                  auth get-or-create-key client.${client}  ${cap})
                ",
    unless  => "ceph --connect-timeout $ceph_connect_timeout -n client.${client} --keyring ${keyring_path} osd stat",
    require => File[$keyring_path],
  }

}
