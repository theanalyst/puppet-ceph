require 'spec_helper'


describe 'ceph::conf::osd' do

  let :title do
    'test_title'
  end

  let :params do
    {'device' => 'foo'}
  end

  let :facts do
    {'hostname' => 'host'}
  end

  it 'should configure defaults' do
    should contain_ceph_config('osd.test_title/host').with({
      'value' => 'host',
      'tag'   => 'osd_config_test_title'
    })
    should contain_ceph_config('osd.test_title/devs').with({
      'value' => 'foo',
      'tag'   => 'osd_config_test_title'
    })
    should_not contain_ceph_config('osd.test_title/osd journal')
    should_not contain_ceph_config('osd.test_title/cluster addr')
    should_not contain_ceph_config('osd.test_title/public addr')
  end

  context 'when setting optional params' do
    before do
      params.merge!({
        'cluster_addr'   => '10.0.0.5',
        'public_addr'    => '10.10.0.5',
        'journal_type'   => 'first_partition',
        'journal_device' => 'jdev',
      })
    end
    it 'should add optional params' do
      should contain_ceph_config('osd.test_title/osd journal').with({
        'value' => 'jdev',
        'tag'   => 'osd_config_test_title'
      })
      should contain_ceph_config('osd.test_title/cluster addr').with({
        'value' => '10.0.0.5',
        'tag'   => 'osd_config_test_title'
      })
      should contain_ceph_config('osd.test_title/public addr').with({
        'value' => '10.10.0.5',
        'tag'   => 'osd_config_test_title'
      })
    end
  end

end
