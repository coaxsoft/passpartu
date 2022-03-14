RSpec.describe Passpartu::Patcher do
  describe '#call' do
    let(:policy_class) { Passpartu::User }

    it 'add method can? to policy_class' do
      described_class.call(policy_class)

      expect(policy_class.new('admin').respond_to?(:can?)).to eq true
    end

    context 'with except attribute' do
      it 'add method can? to policy_class with except param' do
        described_class.call(policy_class)

        expect(policy_class.new('admin').respond_to?(:can?)).to eq true
        expect(policy_class.new('admin').can?(:orders, :edit)).to eq true
      end

      it 'returns false if role excepted' do
        described_class.call(policy_class)

        expect(policy_class.new('admin').respond_to?(:can?)).to eq true
        expect(policy_class.new('admin').can?(:orders, :edit)).to eq true
        expect(policy_class.new('admin').can?(:orders, :edit, except: :admin)).to eq false
      end
    end

    context 'with skip attribute' do
      it 'add method can? to policy_class with skip param' do
        described_class.call(policy_class)

        expect(policy_class.new('admin').respond_to?(:can?)).to eq true
        expect(policy_class.new('admin').can?(:orders, :edit)).to eq true
      end

      it 'returns false if role skipped' do
        described_class.call(policy_class)

        expect(policy_class.new('admin').respond_to?(:can?)).to eq true
        expect(policy_class.new('admin').can?(:orders, :edit)).to eq true
        expect(policy_class.new('admin').can?(:orders, :edit, skip: :admin)).to eq false
        expect(policy_class.new('admin').can?(:orders, :edit, skip: [:admin, :manager])).to eq false
      end
    end

    context 'with skip and except(higher priority) attribute' do
      context 'skip: admin, except: manager' do
        it 'ignores skip param and returns true for admin role' do
          described_class.call(policy_class)

          expect(policy_class.new('admin').respond_to?(:can?)).to eq true
          expect(policy_class.new('admin').can?(:orders, :edit)).to eq true
          expect(policy_class.new('admin').can?(:orders, :edit, skip: :admin, except: :manager)).to eq true
        end

        it 'ignores skip param and returns false for admin role' do
          described_class.call(policy_class)

          expect(policy_class.new('admin').respond_to?(:can?)).to eq true
          expect(policy_class.new('admin').can?(:orders, :edit)).to eq true
          expect(policy_class.new('admin').can?(:orders, :edit, skip: :manager, except: :admin)).to eq false
        end
      end

    end

    context 'with block given' do
      it 'return true for true block' do
        described_class.call(policy_class)

        expect(policy_class.new('admin').respond_to?(:can?)).to eq true

        expect(policy_class.new('admin').can?(:orders, :edit) { 'true' == 'true' } ).to eq true
      end

      it 'return true for false block' do
        described_class.call(policy_class)

        expect(policy_class.new('admin').respond_to?(:can?)).to eq true

        expect(policy_class.new('admin').can?(:orders, :edit) { 'true' == 'false' } ).to eq false
      end
    end

    context 'for roles included in yaml file' do
      it 'should respond to admin and manager ' do
        described_class.call(policy_class)

        expect(policy_class.new('admin').respond_to?(:can?)).to eq true

        expect(policy_class.new('admin').respond_to?(:admin_can?)).to eq true
        expect(policy_class.new('manager').respond_to?(:manager_can?)).to eq true
      end

      it 'should NOT respond to worker' do
        described_class.call(policy_class)

        expect(policy_class.new('admin').respond_to?(:can?)).to eq true

        expect(policy_class.new('admin').respond_to?(:worker_can?)).to eq false
        expect(policy_class.new('manager').respond_to?(:worker_can?)).to eq false
      end

      context 'for admin_can?' do
        it 'returns true for admin' do
          expect(policy_class.new('admin').admin_can?(:orders, :edit)).to eq true
        end

        it 'returns false for manager' do
          expect(policy_class.new('manager').can?(:orders, :edit)).to eq true

          expect(policy_class.new('manager').admin_can?(:orders, :edit)).to eq false
        end

        context 'with block given' do
          it 'returns true for positive block' do
            expect(policy_class.new('admin').admin_can?(:orders, :edit)).to eq true

            expect(policy_class.new('admin').admin_can?(:orders, :edit) { 'true' == 'true' } ).to eq true
          end

          it 'returns false for negative block' do
            expect(policy_class.new('admin').admin_can?(:orders, :edit)).to eq true

            expect(policy_class.new('admin').admin_can?(:orders, :edit) { 'true' == 'false' } ).to eq false
          end
        end
      end

      context 'for manager_can?' do
        it 'returns true for manager' do
          expect(policy_class.new('manager').manager_can?(:orders, :edit)).to eq true
        end

        it 'returns false for admin' do
          expect(policy_class.new('admin').can?(:orders, :edit)).to eq true

          expect(policy_class.new('admin').manager_can?(:orders, :edit)).to eq false
        end
      end

      context 'for not existed role?' do
        it 'returns false' do
          expect(policy_class.new('fake_role').manager_can?(:orders, :edit)).to eq false
        end
      end
    end
  end
end
