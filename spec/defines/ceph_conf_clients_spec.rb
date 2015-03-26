require 'spec_helper'

describe 'ceph::conf::clients' do
  let :title do
    'foo'
  end
  it { should contain_ceph_config('client.foo/keyring').with_value('/etc/ceph/keyring.foo') }
end
