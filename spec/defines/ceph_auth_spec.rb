require 'spec_helper'

describe 'ceph::auth' do

  let :title do
    'foo'
  end

  let :params do
    {
      'mon_key' => 'secret'
    }
  end

  it 'should configure defaults' do
    should contain_file('/etc/ceph/keyring').with({
      'ensure' => 'present',
      'owner'  => 'root',
      'mode'   => '0600'
    })
    should contain_exec('exec_add_ceph_auth_foo').with({
      'command' => "ceph-authtool /etc/ceph/keyring \
                  --name=client.foo --add-key \
                  $(ceph --connect-timeout 5 --name mon. --key 'secret' \
                  auth get-or-create-key client.foo )",
      'unless' => 'ceph --connect-timeout 5 -n client.foo --keyring /etc/ceph/keyring osd stat'
    })
  end
end
