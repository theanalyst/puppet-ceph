require 'spec_helper'

describe 'ceph::conf::mds' do

  let :title do
    '10.1.1.1'
  end

  let :facts do
    {
      :hostname       => 'some-host.foo.tld',
    }
  end

  it 'should configure defaults' do
    should contain_ceph_config('mds.10.1.1.1/host').with_value('some-host.foo.tld')
  end
end
