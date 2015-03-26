require 'spec_helper'

describe 'ceph::conf::radosgw' do

  let :title do
    'test'
  end

  let :params do
    {
      'keystone_url'         => 'http://localhost:5000/v1/',
      'keystone_admin_token' => 'tokens',
    }
  end

  let :facts do
    {'hostname' => 'foohost'}
  end

  it 'should contain default configs' do
    should contain_ceph_config('client.radosgw.gateway/host').with_value('foohost')
    should contain_ceph_config('client.radosgw.gateway/keyring').with_value('/etc/ceph/keyring')
    should contain_ceph_config('client.radosgw.gateway/rgw socket path').with_value('/var/run/ceph/radosgw.sock')
    should contain_ceph_config('client.radosgw.gateway/log file').with_value('/var/log/ceph/radosgw.log')
    should contain_ceph_config('client.radosgw.gateway/rgw keystone url').with_value('http://localhost:5000/v1/')
    should contain_ceph_config('client.radosgw.gateway/rgw keystone admin token').with_value('tokens')
    should contain_ceph_config('client.radosgw.gateway/rgw keystone accepted roles').with_value('Member, admin, swiftoperator')
    should contain_ceph_config('client.radosgw.gateway/rgw keystone token cache size').with_value(500)
    should contain_ceph_config('client.radosgw.gateway/rgw keystone revocation interval').with_value(600)
    should contain_ceph_config('client.radosgw.gateway/rgw s3 auth use keystone').with_value('true')
    should_not contain_ceph_config('client.radosgw.gateway/nss db path')
  end

  context 'with ssl' do
    before do
      params.merge!({'ceph_radosgw_listen_ssl' => true})
    end
    it 'should configure ssl' do
      should contain_ceph_config('client.radosgw.gateway/nss db path').with_value('/var/lib/ceph/nss')
    end
  end

end
