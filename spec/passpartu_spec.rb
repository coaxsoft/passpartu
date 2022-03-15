# frozen_string_literal: true

RSpec.describe Passpartu do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  context 'with default policy' do
    it "set default policy file to './config/passpartu.yml'" do
      expect(described_class.config.policy_file).to eq './config/passpartu.yml'
    end

    context 'when default policy to match policy_file rules' do
      it 'for admin' do
        policy = described_class.config.policy
        expect(policy.dig('admin', 'orders', 'create')).to be true
        expect(policy.dig('admin', 'orders', 'edit')).to be true
        expect(policy.dig('admin', 'orders', 'delete')).to be true

        expect(policy.dig('admin', 'products', 'create')).to be false
        expect(policy.dig('admin', 'products', 'edit')).to be true
        expect(policy.dig('admin', 'products', 'delete')).to be true
      end

      it 'for manager' do
        policy = described_class.config.policy
        expect(policy.dig('manager', 'orders', 'create')).to be true
        expect(policy.dig('manager', 'orders', 'edit')).to be true
        expect(policy.dig('manager', 'orders', 'delete')).to be false

        expect(policy.dig('manager', 'products', 'create')).to be true
        expect(policy.dig('manager', 'products', 'edit')).to be true
        expect(policy.dig('manager', 'products', 'delete')).to be false
      end
    end
  end

  context 'with custom policy' do
    it "set custom policy file to './config/passpartu_custom.yml'" do
      described_class.configure do |config|
        config.policy_file = './config/passpartu_custom.yml'
      end
      expect(described_class.config.policy_file).to eq './config/passpartu_custom.yml'
    end

    context 'with default policy to match policy_file rules' do
      it 'for admin' do
        policy = described_class.config.policy
        expect(policy.dig('admin', 'orders', 'create')).to be false
        expect(policy.dig('admin', 'orders', 'edit')).to be false
        expect(policy.dig('admin', 'orders', 'delete')).to be false

        expect(policy.dig('admin', 'products', 'create')).to be true
        expect(policy.dig('admin', 'products', 'edit')).to be true
        expect(policy.dig('admin', 'products', 'delete')).to be true
      end

      it 'for manager' do
        policy = described_class.config.policy
        expect(policy.dig('manager', 'orders', 'create')).to be true
        expect(policy.dig('manager', 'orders', 'edit')).to be true
        expect(policy.dig('manager', 'orders', 'delete')).to be false

        expect(policy.dig('manager', 'products', 'create')).to be true
        expect(policy.dig('manager', 'products', 'edit')).to be true
        expect(policy.dig('manager', 'products', 'delete')).to be false
      end
    end
  end

  context 'when custom policy file not found' do
    subject(:policy_file) { described_class.configure { |config| config.policy_file = './not_config/not_policy.yml' } }

    it 'raises PolicyYmlNotFoundError' do
      expect { policy_file }.to raise_error(described_class::PolicyYmlNotFoundError)
    end
  end

  context 'when check_waterfall' do
    context 'with true' do
      before { described_class.config.raise_policy_missed_error = true }

      it 'set raise_policy_missed_error to false' do
        expect(described_class.config.raise_policy_missed_error).to be true

        described_class.configure { |config| config.check_waterfall = true }

        expect(described_class.config.raise_policy_missed_error).to be false
      end
    end

    context 'with false' do
      context 'when raise_policy_missed_error: true' do
        before { described_class.config.raise_policy_missed_error = true }

        it 'does not change raise policy missed error' do
          expect(described_class.config.raise_policy_missed_error).to be true

          described_class.configure { |config| config.check_waterfall = true }

          expect(described_class.config.raise_policy_missed_error).to be false
        end
      end

      context 'when raise_policy_missed_error: false' do
        before { described_class.config.raise_policy_missed_error = false }

        it 'does not change raise policy missed error' do
          expect(described_class.config.raise_policy_missed_error).to be false

          described_class.configure { |config| config.check_waterfall = false }

          expect(described_class.config.raise_policy_missed_error).to be false
        end
      end
    end
  end
end
