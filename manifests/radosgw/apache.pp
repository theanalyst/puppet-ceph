# == Class: ceph::radosgw::apache
#
# Configures Apache for radosgw.
#
# === Parameters
#
# [*bind_address*]
#    (optional) Bind address in Apache for Radosgw. (Defaults to '0.0.0.0')
#
# [*listen_ssl*]
#    (optional) Enable SSL support in Apache. (Defaults to false)
#
# [*radosgw_cert*]
#    (required with listen_ssl) Certificate to use for SSL support.
#
# [*radosgw_key*]
#    (required with listen_ssl) Private key to use for SSL support.
#
# [*radosgw_ca*]
#    (required with listen_ssl) CA certificate to use for SSL support.
#
# [*headers*]
#   Array of heders to be added to the vhost.
#

class ceph::radosgw::apache (
  $bind_address           = '0.0.0.0',
  $serveradmin_email      = 'root@localhost',
  $server_name            = 'localhost',
  $fastcgi_ext_script     = '/var/www/s3gw.fcgi',
  $fastcgi_ext_socket     = '/var/run/ceph/radosgw.sock',
  $listen_port_http       = 80,
  $listen_port_https      = 443,
  $listen_ssl             = false,
  $radosgw_cert_file      = undef,
  $radosgw_key_file       = undef,
  $radosgw_ca_file        = undef,
  $docroot                = '/var/www',
  $priority               = 25,
  $headers                = undef,
) {

  include ceph::radosgw::params
  include ::apache
  include ::apache::mod::fastcgi
  include ::apache::mod::rewrite
  include ::apache::mod::headers


  Package['radosgw'] -> Package[$::ceph::radosgw::params::http_service]


  file { $fastcgi_ext_script:
    ensure  => file,
    owner   => root,
    group   => $::ceph::radosgw::params::apache_group,
    mode    => '0750',
    content => "#!/bin/sh\nexec /usr/bin/radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway",
    notify  => Service['httpd'],
  }

  apache::vhost { 'radosgw':
    servername            => $server_name,
    serveradmin           => $serveradmin_email,
    docroot               => $docroot,
    port                  => $listen_port_http,
    ssl                   => false,
    error_log_file        => 'radosgw_error.log',
    access_log_file       => 'radosgw.log',
    fastcgi_server        => $fastcgi_ext_script,
    fastcgi_socket        => $fastcgi_ext_socket,
    fastcgi_dir           => $docroot,
    allow_encoded_slashes => 'on',
    headers              => $headers,
    custom_fragment       => '
  <If "-z resp(\'CONTENT-TYPE\')">
    Header set Content-Type "application/octet-stream"
  </If>', 
    rewrites              =>  [{
                                rewrite_rule => ['^/(.*) /s3gw.fcgi?%{QUERY_STRING} [E=HTTP_AUTHORIZATION:%{HTTP:Authorization},L]']
                              }],
    require               => [Package['radosgw'],
                              File[$fastcgi_ext_script]],
  }

  ##
  # A workaround to avoid swift client errors becuase of content-type missing
  # while downloading the object.
  # NOTE: this is just a workaround and should be removed once the issue fixed
  # on radosgw code (I hope this is fixed in Giant, otherwise Ill file a bug)
  ##

  ##
  # Apache module dont have conditional contentype injecting configuration code,
  # so just adding it here. Just copying small chunk of code from Apache module
  # and customizing here (and template too).
  ##

  if $listen_ssl {
    include apache::mod::ssl

    if $radosgw_ca_file == undef {
      fail('The radosgw_ca parameter is required when listen_ssl is true')
    }

    if $radosgw_cert_file == undef {
      fail('The radosgw_cert parameter is required when listen_ssl is true')
    }

    if $radosgw_key_file == undef {
      fail('The radosgw_key parameter is required when listen_ssl is true')
    }

  }

}
