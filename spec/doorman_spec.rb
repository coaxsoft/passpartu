RSpec.describe Doorman do
  it 'has a version number' do
    expect(Doorman::VERSION).not_to be nil
  end

  it 'set User class by default' do
    expect(Doorman.config.policy_class).to eq User
  end

  it "set default policy file to './config/doorman.yml'" do
    Doorman.configure {}
    expect(Doorman.config.policy_file).to eq './config/doorman.yml'
  end

  it 'set default policy to match policy_file rules for admin' do
    policy = Doorman.config.policy
    expect(policy.dig('admin', 'orders', 'create')).to eq true
    expect(policy.dig('admin', 'orders', 'edit')).to eq true
    expect(policy.dig('admin', 'orders', 'delete')).to eq true

    expect(policy.dig('admin', 'products', 'create')).to eq false
    expect(policy.dig('admin', 'products', 'edit')).to eq true
    expect(policy.dig('admin', 'products', 'delete')).to eq true
  end

  it 'set default policy to match policy_file rules for manager' do
    policy = Doorman.config.policy
    expect(policy.dig('manager', 'orders', 'create')).to eq true
    expect(policy.dig('manager', 'orders', 'edit')).to eq true
    expect(policy.dig('manager', 'orders', 'delete')).to eq false

    expect(policy.dig('manager', 'products', 'create')).to eq true
    expect(policy.dig('manager', 'products', 'edit')).to eq true
    expect(policy.dig('manager', 'products', 'delete')).to eq false
  end
end
