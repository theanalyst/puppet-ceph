require 'spec_helper'

describe 'ceph::conf::mon_config' do
  let :title do
    '10.1.1.1'
  end
  it 'should configure defaults' do
    should contain_ceph_config('mon.10.1.1.1/host').with_value('10.1.1.1')
    should contain_ceph_config('mon.10.1.1.1/mon addr').with_value('10.1.1.1:6789')
  end
end
