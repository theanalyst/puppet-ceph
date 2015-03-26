require 'spec_helper'

describe 'ceph::conf' do

  let :params do
    { :fsid => 'qwertyuiop', }
  end

  it { should contain_class('ceph::package') }

  describe "with default parameters" do

    it 'should create ceph config' do
      should contain_ceph_config('global/keyring').with_value('/etc/ceph/keyring')
      should contain_ceph_config('global/fsid').with_value('qwertyuiop')
      should contain_ceph_config('global/osd pool default size').with_value(3)
      should contain_ceph_config('global/osd pool default pg num').with_value(1024)
      should contain_ceph_config('global/osd pool default pgp num').with_value(1024)
      should contain_ceph_config('global/auth cluster required').with_value('cephx')
      should contain_ceph_config('global/auth service required').with_value('cephx')
      should contain_ceph_config('global/auth client required').with_value('cephx')
      should contain_ceph_config('mon/mon data').with_value('/var/lib/ceph/mon/mon.$id')
      should contain_ceph_config('osd/filestore flusher').with({
        'value' => false,
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('osd/osd data').with({
        'value' => '/var/lib/ceph/osd/ceph-$id',
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('osd/osd mkfs type').with({
        'value' => 'xfs',
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('osd/keyring').with({
        'value' => '/var/lib/ceph/osd/ceph-$id/keyring',
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('osd/osd journal').with({
        'value' => '/var/lib/ceph/osd/ceph-$id/journal',
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('osd/osd journal size').with({
        'value' => 4096,
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('mds/mds data').with_value('/var/lib/ceph/mds/ceph-$id')
      should contain_ceph_config('mds/keyring').with_value('/var/lib/ceph/mds/ceph-$id/keyring')
    end

    context 'when unsetting auth type' do
      before do
        params.merge!({'auth_type' => false})
      end
      it 'should not configure auth' do
        should_not contain_ceph_config('global/auth cluster required')
        should_not contain_ceph_config('global/auth service required')
        should_not contain_ceph_config('global/auth client required')
      end
    end
  end

  describe "when overriding default parameters" do

    let :params do
      {
        :fsid                    => 'qwertyuiop',
        :auth_type               => 'dummy',
        :signatures_require      => 'true',
        :signatures_cluster      => 'true',
        :signatures_service      => 'true',
        :signatures_sign_msgs    => 'true',
        :pool_default_pg_num     => 16,
        :pool_default_pgp_num    => 16,
        :pool_default_min_size   => 8,
        :pool_default_crush_rule => 1,
        :osd_journal_type        => 'other',
        :journal_size_mb         => 8192,
        :cluster_network         => '10.0.0.0/16',
        :public_network          => '10.1.0.0/16',
        :mon_data                => '/opt/ceph/mon._id',
        :mon_timecheck_interval  => 2,
        :mon_init_members        => 'a , b , c',
        :osd_data                => '/opt/ceph/osd._id',
        :mds_data                => '/opt/ceph/mds._id'
      }
    end

    it 'should create ceph config' do
      should contain_ceph_config('global/osd pool default pg num').with_value(16)
      should contain_ceph_config('global/osd pool default pgp num').with_value(16)
      should contain_ceph_config('global/auth cluster required').with_value('dummy')
      should contain_ceph_config('global/auth service required').with_value('dummy')
      should contain_ceph_config('global/auth client required').with_value('dummy')
      should contain_ceph_config('global/cephx require signatures').with_value('true')
      should contain_ceph_config('global/cephx cluster require signatures').with_value('true')
      should contain_ceph_config('global/cephx service require signatures').with_value('true')
      should contain_ceph_config('global/cephx sign messages').with_value('true')
      should contain_ceph_config('mon/mon data').with_value('/opt/ceph/mon._id')
      should contain_ceph_config('global/mon timecheck interval').with_value(2)
      should contain_ceph_config('mon/mon initial members').with_value('a , b , c')
      should contain_ceph_config('osd/osd data').with({
        'value' => '/opt/ceph/osd._id',
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('osd/osd mkfs type').with({
        'value' => 'xfs',
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('osd/keyring').with({
        'value' => '/opt/ceph/osd._id/keyring',
        'tag'   => 'osd_config',
      })
      should contain_ceph_config('global/osd pool default min size').with_value(8)
      should contain_ceph_config('global/osd pool default crush rule').with_value(1)
      should_not contain_ceph_config('osd/osd journal')
      should_not contain_ceph_config('osd/osd journal size')
      should contain_ceph_config('mds/mds data').with_value('/opt/ceph/mds._id')
      should contain_ceph_config('mds/keyring').with_value('/opt/ceph/mds._id/keyring')
    end
  end
end
