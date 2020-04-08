RSpec.describe Passpartu do
  it 'has a version number' do
    expect(Passpartu::VERSION).not_to be nil
  end

  context 'default policy' do
    it "set default policy file to './config/passpartu.yml'" do
      expect(Passpartu.config.policy_file).to eq './config/passpartu.yml'
    end

    it 'set default policy to match policy_file rules for admin' do
      policy = Passpartu.config.policy
      expect(policy.dig('admin', 'orders', 'create')).to eq true
      expect(policy.dig('admin', 'orders', 'edit')).to eq true
      expect(policy.dig('admin', 'orders', 'delete')).to eq true

      expect(policy.dig('admin', 'products', 'create')).to eq false
      expect(policy.dig('admin', 'products', 'edit')).to eq true
      expect(policy.dig('admin', 'products', 'delete')).to eq true
    end

    it 'set default policy to match policy_file rules for manager' do
      policy = Passpartu.config.policy
      expect(policy.dig('manager', 'orders', 'create')).to eq true
      expect(policy.dig('manager', 'orders', 'edit')).to eq true
      expect(policy.dig('manager', 'orders', 'delete')).to eq false

      expect(policy.dig('manager', 'products', 'create')).to eq true
      expect(policy.dig('manager', 'products', 'edit')).to eq true
      expect(policy.dig('manager', 'products', 'delete')).to eq false
    end
  end

  context 'custom policy' do
    it "set custom policy file to './config/passpartu_custom.yml'" do
      Passpartu.configure do |config|
        config.policy_file = './config/passpartu_custom.yml'
      end
      expect(Passpartu.config.policy_file).to eq './config/passpartu_custom.yml'
    end

    it 'set default policy to match policy_file rules for admin' do
      policy = Passpartu.config.policy
      expect(policy.dig('admin', 'orders', 'create')).to eq false
      expect(policy.dig('admin', 'orders', 'edit')).to eq false
      expect(policy.dig('admin', 'orders', 'delete')).to eq false

      expect(policy.dig('admin', 'products', 'create')).to eq true
      expect(policy.dig('admin', 'products', 'edit')).to eq true
      expect(policy.dig('admin', 'products', 'delete')).to eq true
    end

    it 'set default policy to match policy_file rules for manager' do
      policy = Passpartu.config.policy
      expect(policy.dig('manager', 'orders', 'create')).to eq true
      expect(policy.dig('manager', 'orders', 'edit')).to eq true
      expect(policy.dig('manager', 'orders', 'delete')).to eq false

      expect(policy.dig('manager', 'products', 'create')).to eq true
      expect(policy.dig('manager', 'products', 'edit')).to eq true
      expect(policy.dig('manager', 'products', 'delete')).to eq false
    end
  end

  context 'when custom policy file not found' do
    it 'raises PolicyYmlNotFoundError' do
      expect { Passpartu.configure { |config| config.policy_file = './not_config/not_policy.yml' } }.to raise_error(Passpartu::PolicyYmlNotFoundError)
    end
  end
end
