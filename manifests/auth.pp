# Define ceph::auth
# To add cephx keys for various client.
#

define ceph::auth (
  $mon_key,
  $client       = $name,
  $file_owner   = 'root',
  $keyring_path = '/etc/ceph/keyring',
  $cap          = undef,
) {

  file { $keyring_path:
    ensure => present,
    owner  => $file_owner,
    mode   => '0600',
  }

  exec { "exec_add_ceph_auth_${client}":
    command =>  "ceph-authtool ${keyring_path} \
                  --name=client.${client} --add-key \
                  $(ceph --name mon. --key '${mon_key}' \
                  auth get-or-create-key client.${client}  ${cap})
                ",
    unless  => "ceph -n client.${client} --keyring ${keyring_path} osd stat",
    require => File[$keyring_path],
  }

}
