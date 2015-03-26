require 'spec_helper'

describe 'ceph::conf::mon' do

  let :pre_condition do
'
class { "ceph::conf": fsid => "1234567890" }
'
  end

  let :title do
    '10.1.1.1'
  end

  let :params do
    {
      'mon_addr' => '1.2.3.4',
      'mon_port' => '1234',
    }
  end

  let :facts do
    {
      :hostname       => 'some-host.foo.tld',
    }
  end

  describe "writes the mon configuration file" do
  end

  it 'should configure defaults' do
    should contain_ceph_config('mon.10.1.1.1/host').with_value('some-host.foo.tld')
    should contain_ceph_config('mon.10.1.1.1/mon addr').with_value('1.2.3.4:1234')
  end
end
