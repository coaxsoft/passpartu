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

    context 'crud true' do
      context 'for admin' do
        let(:role) { 'admin' }

        it 'returns true for orders create' do
          expect(described_class.call(role, %i[items create])).to eq true
        end

        it 'returns true for orders read' do
          expect(described_class.call(role, %i[items read])).to eq true
        end

        it 'returns true for orders update' do
          expect(described_class.call(role, %i[items update])).to eq true
        end

        it 'returns true for orders delete' do
          expect(described_class.call(role, %i[items delete])).to eq true
        end
      end

      context 'read false' do
        before(:each) do
          Passpartu.policy['admin']['items']['delete'] = false
        end

        after do
          Passpartu.configure {}
        end

        context 'for admin' do
          let(:role) { 'admin' }

          it 'returns true for orders create' do
            expect(described_class.call(role, %i[items create])).to eq true
          end

          it 'returns false for orders read' do
            expect(described_class.call(role, %i[items read])).to eq true
          end

          it 'returns true for orders update' do
            expect(described_class.call(role, %i[items update])).to eq true
          end

          it 'overrides crud true and returns false for orders delete' do
            expect(described_class.call(role, %i[items delete])).to eq false
          end
        end
      end
    end
  end
end
