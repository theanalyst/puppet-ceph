## Define ceph::auth
define ceph::auth (
  $mon_key,
  $client = $name,
  $file_owner = 'root',
  $keyring_path = "/etc/ceph/keyring",
  $cap = undef,  
) {

  file { $keyring_path:
    owner   => $file_owner,
    ensure  => present,
    mode    => 600,
  } 

  exec { "exec_add_ceph_auth_${client}":
    command => "ceph-authtool /tmp/.exec_add_ceph_auth_admin_${client}.tmp \
                --create-keyring \
                --name=mon. \
                --add-key='${mon_key}' \
                --cap mon 'allow *' && ceph-authtool $keyring_path \
                --name=client.$client \
                --add-key \
                  $(ceph --name mon. --keyring /tmp/.exec_add_ceph_auth_admin_${client}.tmp \
                  auth get-or-create-key client.${client}  $cap ) && rm -f /tmp/.exec_add_ceph_auth_admin_${client}.tmp ",
    unless  => "ceph -n client.$client --keyring $keyring_path osd stat",
    require => File["$keyring_path"],
  }

}
