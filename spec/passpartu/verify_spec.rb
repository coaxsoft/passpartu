require 'byebug'

RSpec.describe Passpartu::Verify do
  describe '#call' do
    let(:policy_class) { Passpartu.config.policy_class }

    context 'for admin' do
      let(:role) { 'admin' }

      it 'returns true for orders create' do
        expect(described_class.call(role, %i[orders create])).to eq true
      end

      it 'returns true for orders delete' do
        expect(described_class.call(role, %i[orders delete])).to eq true
      end
    end

    context 'for maanger' do
      let(:role) { 'manager' }

      it 'returns true for orders create' do
        expect(described_class.call(role, %i[orders create])).to eq true
      end

      it 'returns true for orders delete' do
        expect(described_class.call(role, %i[orders delete])).to eq false
      end
    end
  end
end
