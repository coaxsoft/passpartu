RSpec.describe Passpartu::CheckWaterfall do
  describe '#call' do
    let(:policy_class) { Passpartu.config.policy_class }

    context 'for admin' do
      let(:role) { 'admin'}

      it 'returns true for existed key' do
        expect(described_class.call(role, %w[orders create])).to eq true
      end

      it 'returns false for existed key' do
        expect(described_class.call(role, %w[products create])).to eq false
      end

      it 'returns nil for non existed key' do
        expect(described_class.call(role, %w[products computers create])).to eq nil
      end
    end

    context 'for super_admin' do
      let(:role) { 'super_admin'}

      it 'returns true for existed key' do
        expect(described_class.call(role, %w[orders create])).to eq true
      end

      it 'returns true for existed key' do
        expect(described_class.call(role, %w[products create])).to eq true
      end

      it 'returns nil for non existed key' do
        expect(described_class.call(role, %w[products computers create])).to eq true
      end
    end

    context 'for super_looser' do
      let(:role) { 'super_looser'}

      it 'returns false for existed key' do
        expect(described_class.call(role, %w[orders create])).to eq false
      end

      it 'returns false for existed key' do
        expect(described_class.call(role, %w[products create])).to eq false
      end

      it 'returns false for non existed key' do
        expect(described_class.call(role, %w[products computers create])).to eq false
      end
    end

    context 'for medium_looser' do
      let(:role) { 'medium_looser'}

      it 'returns true for existed key' do
        expect(described_class.call(role, %w[orders create])).to eq true
      end

      it 'returns false for existed key' do
        expect(described_class.call(role, %w[orders delete])).to eq false
      end

      it 'returns true for non existed key' do
        expect(described_class.call(role, %w[products computers create])).to eq true
      end
    end
  end
end
