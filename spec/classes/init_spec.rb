require 'spec_helper'
describe('neo4j', :type => :class) do
  let(:node) { 'testhost.example.com' }

  context 'with defaults for all parameters' do
    let(:title) {'neo4j'}
    let(:facts) { {
      :kernel => 'Linux'
    } }
    it { should contain_class('neo4j') }
    it {
      should contain_user('neo4j').with ({
        'ensure' => 'present',
        'home'   => "#{install_prefix}",
        })
    }
    it {
      should contain_group('neo4j').with ({
        'ensure' => 'present',
        })
    }
    it {
      should contain_file("#{install_prefix}")
      .with(
        'ensure' => 'directory',
        'owner' => 'neo4j',
        'group' => 'neo4j',
        )
    }
  end

  describe 'when called with no parameters on redhat' do
    let(:facts) { {
      :osfamily => 'Debian',
      :operatingsystem => 'Ubuntu',
      :kernel => 'Linux',
    } }
    it {
      should contain_package('wget')
    }
  end
end
