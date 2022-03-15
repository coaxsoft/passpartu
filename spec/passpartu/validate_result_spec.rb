# frozen_string_literal: true

RSpec.describe Passpartu::ValidateResult do
  describe '#call' do
    subject(:response) { |ex|; described_class.call(ex.metadata[:result]) }

    context 'with raise_policy_missed_error: true' do
      before { Passpartu.config.raise_policy_missed_error = true }

      it 'with true', result: true do
        expect(response).to be true
      end

      it 'with false', result: false do
        expect(response).to be false
      end

      context 'with hash', result: {} do
        it 'raises PolicyMissedError' do
          expect { response }.to raise_error described_class::PolicyMissedError
        end
      end

      context 'with nil', result: nil do
        it 'raises PolicyMissedError' do
          expect { response }.to raise_error described_class::PolicyMissedError
        end
      end
    end

    context 'with raise_policy_missed_error: false' do
      before { Passpartu.config.raise_policy_missed_error = false }

      it 'with true', result: true do
        expect(response).to be true
      end

      it 'with false', result: false do
        expect(response).to be false
      end

      it 'with hash', result: {} do
        expect(response).to be false
      end

      it 'with nil', result: nil do
        expect(response).to be false
      end
    end
  end
end
