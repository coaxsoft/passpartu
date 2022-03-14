RSpec.describe Passpartu::ValidateResult do
  describe '#call' do
    subject { |ex|; described_class.call(ex.metadata[:result]) }

    context 'with raise_policy_missed_error: true' do
      before { Passpartu.config.raise_policy_missed_error = true }

      context 'with true', result: true do
        it { is_expected.to eq true }
      end

      context 'with false', result: false do
        it { is_expected.to eq false }
      end

      context 'with hash', result: {} do
        it 'raises PolicyMissedError' do
          expect { subject }.to raise_error described_class::PolicyMissedError
        end
      end

      context 'with nil', result: nil do
        it 'raises PolicyMissedError' do
          expect { subject }.to raise_error described_class::PolicyMissedError
        end
      end
    end

    context 'with raise_policy_missed_error: false' do
      before { Passpartu.config.raise_policy_missed_error = false }

      context 'with true', result: true do
        it { is_expected.to eq true }
      end

      context 'with false', result: false do
        it { is_expected.to eq false }
      end

      context 'with hash', result: {} do
        it { is_expected.to eq false }
      end

      context 'with nil', result: nil do
        it { is_expected.to eq false }
      end
    end
  end
end
