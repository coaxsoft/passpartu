RSpec.describe Passpartu::Verify do
  describe '#call' do
    let(:policy_class) { Passpartu.config.policy_class }

    before { Passpartu.config.raise_policy_missed_error = true }

    subject { |ex|; described_class.call(ex.metadata[:role], [ex.metadata[:resource], ex.metadata[:action]]) }

    context 'Orders', resource: :orders do
      context 'for admin', role: :admin do
        it 'returns true for orders create', action: :create do
          is_expected.to eq true
        end

        it 'returns true for orders delete', action: :delete do
          is_expected.to eq true
        end
      end

      context 'for manger', role: :manager do
        it 'returns true for orders create', action: :create do
          is_expected.to eq true
        end

        it 'returns true for orders delete', action: :delete do
          is_expected.to eq false
        end
      end
    end

    context 'crud true' do
      context 'for admin', role: :admin do
        context 'Items', resource: :items do
          it 'returns true for orders create', action: :create do
            is_expected.to eq true
          end

          it 'returns true for orders read', action: :read do
            is_expected.to eq true
          end

          it 'returns true for orders update', action: :update do
            is_expected.to eq true
          end

          it 'returns true for orders delete', action: :delete do
            is_expected.to eq true
          end
        end
      end

      context 'read false' do
        before(:each) { Passpartu.policy['admin']['items']['delete'] = false }

        after { Passpartu.configure {} }

        context 'for admin', role: :admin do
          context 'Items', resource: :items do
            it 'returns true for orders create', action: :create do
              is_expected.to eq true
            end

            it 'returns false for orders read', action: :read do
              is_expected.to eq true
            end

            it 'returns true for orders update', action: :update do
              is_expected.to eq true
            end

            it 'overrides crud true and returns false for orders delete', action: :delete do
              is_expected.to eq false
            end

            context 'misspelled' do
              context 'raise policy_missed_error true' do
                it 'raises an error if its not crud action', action: :crea do
                  expect { subject }.to raise_error Passpartu::ValidateResult::PolicyMissedError
                end

                it 'raises an error if its not crud action', action: :rea do
                  expect { subject }.to raise_error Passpartu::ValidateResult::PolicyMissedError
                end

                it 'raises an error if its not crud action', action: :upde do
                  expect { subject }.to raise_error Passpartu::ValidateResult::PolicyMissedError
                end

                it 'raises an error if its not crud action', action: :dele do
                  expect { subject }.to raise_error Passpartu::ValidateResult::PolicyMissedError
                end
              end

              context 'raise policy_missed_error false' do
                before(:each) { Passpartu.config.raise_policy_missed_error = false }

                it 'returns false for orders create', action: :crea do
                  is_expected.to eq false
                end

                it 'returns false for orders read', action: :rea do
                  is_expected.to eq false
                end

                it 'returns false for orders update', action: :upde do
                  is_expected.to eq false
                end

                it 'returns false for orders delete', action: :dele do
                  is_expected.to eq false
                end
              end
            end
          end
        end
      end
    end

    context 'expect param' do
      context 'admin' do
        let(:role) { :admin }
        let(:except) { :admin }

        it 'returns false for admin and true for manager' do
          expect(described_class.call(role, %i[orders create])).to eq true

          expect(described_class.call(role, %i[orders create], except: except)).to eq false
          expect(described_class.call(:manager, %i[orders create], except: except)).to eq true
        end
      end

      context 'admin and manger' do
        let(:except) { %i[admin manager] }

        it 'returns false for admin and manager' do
          expect(described_class.call(:admin, %i[orders create])).to eq true
          expect(described_class.call(:manager, %i[orders create])).to eq true

          expect(described_class.call(:admin, %i[orders create], except: except)).to eq false
          expect(described_class.call(:manager, %i[orders create], except: except)).to eq false
        end
      end
    end

    context 'only param' do
      context 'admin' do
        let(:role) { :admin }
        let(:only) { :admin }

        it 'returns true for admin and false for manager' do
          expect(described_class.call(role, %i[orders create])).to eq true

          expect(described_class.call(role, %i[orders create], only: only)).to eq true
          expect(described_class.call(:manager, %i[orders create], only: only)).to eq false
        end
      end

      context 'admin and manger' do
        let(:only) { %i[admin manager] }

        it 'returns false for admin and manager' do
          expect(described_class.call(:admin, %i[orders create])).to eq true
          expect(described_class.call(:manager, %i[orders create])).to eq true

          expect(described_class.call(:admin, %i[orders create], only: only)).to eq true
          expect(described_class.call(:manager, %i[orders create], only: only)).to eq true
          expect(described_class.call(:worker, %i[orders create], only: only)).to eq false
        end
      end
    end

    context 'only & except param' do
      context 'admin' do
        let(:role) { :admin }
        let(:only) { :admin }
        let(:except) { :admin }

        it 'returns true for admin' do
          expect(described_class.call(role, %i[orders create], only: only, except: except)).to eq true
        end
      end

      context 'admin and manger' do
        it 'returns true for admin and false for manager' do
          expect(described_class.call(:admin, %i[orders create], only: :admin, except: :manager)).to eq true
          expect(described_class.call(:manager, %i[orders create], only: :admin, except: :manager)).to eq false
        end

        it 'returns true for admin and manager' do
          expect(described_class.call(:admin, %i[orders create], only: [:admin, :manager], except: :manager)).to eq true
          expect(described_class.call(:manager, %i[orders create], only: [:admin, :manager], except: :manager)).to eq true
        end
      end
    end
  end

  context 'check_waterfall' do
    subject { |ex|; described_class.call(ex.metadata[:role], [*ex.metadata[:resources] || :orders, ex.metadata[:action]]) }

    around(:each) do |example|
      Passpartu.config.check_waterfall = true
      example.run
      Passpartu.config.check_waterfall = false
    end

    it 'returns true for super_admin' do
      expect(described_class.call(:super_admin, %i[action])).to eq true
      expect(described_class.call(:super_admin, %i[nested action])).to eq true
      expect(described_class.call(:super_admin, %i[deep nested action])).to eq true
      expect(described_class.call(:super_admin, %i[very deep nested action])).to eq true
    end

    it 'returns false for super_looser' do
      expect(described_class.call(:super_looser, %i[action])).to eq false
      expect(described_class.call(:super_looser, %i[nested action])).to eq false
      expect(described_class.call(:super_looser, %i[deep nested action])).to eq false
      expect(described_class.call(:super_looser, %i[very deep nested action])).to eq false
    end

    around(:each) do |example|
      Passpartu.config.check_waterfall = true
      example.run
      Passpartu.config.check_waterfall = false
    end

    context 'for admin', role: :admin do
      it 'returns true for existed action', resources: %i[orders], action: :create do
        is_expected.to eq true
      end

      it 'returns false for existed action', resources: %i[products], action: :create do
        is_expected.to eq false
      end

      it 'returns false for non existed action', resources: %i[products computers], action: :create do
        is_expected.to eq false
      end
    end

    context 'for super_admin', role: :super_admin do
      it 'returns true for existed action', resources: %i[orders], action: :create do
        is_expected.to eq true
      end

      it 'returns true for existed action', resources: %i[products], action: :create do
        is_expected.to eq true
      end

      it 'returns nil for non existed action', resources: %i[products computers], action: :create do
        is_expected.to eq true
      end
    end

    context 'for super_looser', role: :super_looser do
      it 'returns false for existed action', resources: %i[orders], action: :create do
        is_expected.to eq false
      end

      it 'returns false for existed action', resources: %i[products], action: :create do
        is_expected.to eq false
      end

      it 'returns false for non existed action', resources: %i[products computers], action: :create do
        is_expected.to eq false
      end
    end

    context 'for medium_looser', role: :medium_looser do
      it 'returns true for existed action', action: :create do
        is_expected.to eq true
      end

      it 'returns false for existed action', action: :delete do
        is_expected.to eq false
      end

      it 'returns true for non existed key', resources: %i[products computers], action: :create do
        is_expected.to eq true
      end
    end
  end
end
