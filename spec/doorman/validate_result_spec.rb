require 'byebug'

RSpec.describe Doorman::ValidateResult do
  describe '#call' do
    context 'with raise_policy_missed_error: true' do
      context 'with true' do
        it 'returns true' do
          expect(described_class.call(true)).to eq true
        end
      end

      context 'with false' do
        it 'returns false' do
          expect(described_class.call(false)).to eq false
        end
      end

      context 'with hash' do
        it 'raises PolicyMissedError' do
          expect { described_class.call({}) }.to raise_error described_class::PolicyMissedError
        end
      end

      context 'with nil' do
        it 'raises PolicyMissedError' do
          expect { described_class.call({}) }.to raise_error described_class::PolicyMissedError
        end
      end
    end

    context 'with raise_policy_missed_error: false' do
      before do
        Doorman.config.raise_policy_missed_error = false
      end
      context 'with true' do
        it 'returns true' do
          expect(described_class.call(true)).to eq true
        end
      end

      context 'with false' do
        it 'returns false' do
          expect(described_class.call(false)).to eq false
        end
      end

      context 'with hash' do
        it 'returns false' do
          expect(described_class.call({})).to eq false
        end
      end

      context 'with nil' do
        it 'returns false' do
          expect(described_class.call({})).to eq false
        end
      end
    end
  end
end
