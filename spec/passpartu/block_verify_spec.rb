# frozen_string_literal: true

RSpec.describe Passpartu::BlockVerify do
  describe '#call' do
    subject(:response) do |ex|
      described_class.call(ex.metadata[:role], [ex.metadata[:resource], ex.metadata[:action]])
    end

    let(:policy_class) { Passpartu.config.policy_class }

    before { Passpartu.config.raise_policy_missed_error = true }

    context 'with Orders', resource: :orders do
      context 'when admin', role: :admin do
        it 'returns true for orders create', action: :create do
          expect(response).to be true
        end

        it 'returns true for orders delete', action: :delete do
          expect(response).to be true
        end
      end

      context 'when manger', role: :manager do
        it 'returns true for orders create', action: :create do
          expect(response).to be true
        end

        it 'returns true for orders delete', action: :delete do
          expect(response).to be false
        end
      end
    end

    context 'when crud true' do
      context 'when admin', role: :admin do
        context 'with Items', resource: :items do
          it 'returns true for orders create', action: :create do
            expect(response).to be true
          end

          it 'returns true for orders read', action: :read do
            expect(response).to be true
          end

          it 'returns true for orders update', action: :update do
            expect(response).to be true
          end

          it 'returns true for orders delete', action: :delete do
            expect(response).to be true
          end
        end
      end

      context 'when read false' do
        before { Passpartu.policy['admin']['items']['delete'] = false }

        after { Passpartu.configure {} }

        context 'when admin', role: :admin do
          context 'with Items', resource: :items do
            it 'returns true for orders create', action: :create do
              expect(response).to be true
            end

            it 'returns false for orders read', action: :read do
              expect(response).to be true
            end

            it 'returns true for orders update', action: :update do
              expect(response).to be true
            end

            it 'overrides crud true and returns false for orders delete', action: :delete do
              expect(response).to be false
            end

            context 'with misspelled' do
              context 'when raise policy_missed_error true' do
                it 'raises an error if its not crud action', action: :crea do
                  expect { response }.to raise_error Passpartu::ValidateResult::PolicyMissedError
                end

                it 'raises an error if its not crud action', action: :rea do
                  expect { response }.to raise_error Passpartu::ValidateResult::PolicyMissedError
                end

                it 'raises an error if its not crud action', action: :upde do
                  expect { response }.to raise_error Passpartu::ValidateResult::PolicyMissedError
                end

                it 'raises an error if its not crud action', action: :dele do
                  expect { response }.to raise_error Passpartu::ValidateResult::PolicyMissedError
                end
              end

              context 'when raise policy_missed_error false' do
                before { Passpartu.config.raise_policy_missed_error = false }

                it 'returns false for orders create', action: :crea do
                  expect(response).to be false
                end

                it 'returns false for orders read', action: :rea do
                  expect(response).to be false
                end

                it 'returns false for orders update', action: :upde do
                  expect(response).to be false
                end

                it 'returns false for orders delete', action: :dele do
                  expect(response).to be false
                end
              end
            end
          end
        end
      end
    end

    context 'with expect param' do
      context 'when admin' do
        let(:role) { :admin }
        let(:except) { :admin }

        it 'returns false for admin and true for manager' do
          expect(described_class.call(role, %i[orders create])).to be true

          expect(described_class.call(role, %i[orders create], except: except)).to be false
          expect(described_class.call(:manager, %i[orders create], except: except)).to be true
        end
      end

      context 'when admin and manger' do
        let(:except) { %i[admin manager] }

        it 'returns false for admin and manager' do
          expect(described_class.call(:admin, %i[orders create])).to be true
          expect(described_class.call(:manager, %i[orders create])).to be true

          expect(described_class.call(:admin, %i[orders create], except: except)).to be false
          expect(described_class.call(:manager, %i[orders create], except: except)).to be false
        end
      end
    end

    context 'with only param' do
      context 'when admin' do
        let(:role) { :admin }
        let(:only) { :admin }

        it 'returns true for admin and false for manager' do
          expect(described_class.call(role, %i[orders create])).to be true

          expect(described_class.call(role, %i[orders create], only: only)).to be true
          expect(described_class.call(:manager, %i[orders create], only: only)).to be false
        end
      end

      context 'when admin and manger' do
        let(:only) { %i[admin manager] }

        it 'returns false for admin and manager' do
          expect(described_class.call(:admin, %i[orders create])).to be true
          expect(described_class.call(:manager, %i[orders create])).to be true

          expect(described_class.call(:admin, %i[orders create], only: only)).to be true
          expect(described_class.call(:manager, %i[orders create], only: only)).to be true
          expect(described_class.call(:worker, %i[orders create], only: only)).to be false
        end
      end
    end

    context 'when only & except param' do
      context 'when admin' do
        let(:role) { :admin }
        let(:only) { :admin }
        let(:except) { :admin }

        it 'returns true for admin' do
          expect(described_class.call(role, %i[orders create], only: only, except: except)).to be true
        end
      end

      context 'when admin and manger' do
        it 'returns true for admin and false for manager' do
          expect(described_class.call(:admin, %i[orders create], only: :admin, except: :manager)).to be true
          expect(described_class.call(:manager, %i[orders create], only: :admin, except: :manager)).to be false
        end

        it 'returns true for admin and manager' do
          expect(described_class.call(:admin, %i[orders create], only: %i[admin manager], except: :manager)).to be true
          expect(described_class.call(:manager, %i[orders create], only: %i[admin manager],
                                      except: :manager)).to be true
        end
      end
    end
  end

  context 'with check_waterfall' do
    subject(:response) do |ex|
      described_class.call(ex.metadata[:role], [*ex.metadata[:resources] || :orders, ex.metadata[:action]])
    end

    around do |example|
      Passpartu.config.check_waterfall = true
      example.run
      Passpartu.config.check_waterfall = false
    end

    it 'returns true for super_admin' do
      expect(described_class.call(:super_admin, %i[action])).to be true
      expect(described_class.call(:super_admin, %i[nested action])).to be true
      expect(described_class.call(:super_admin, %i[deep nested action])).to be true
      expect(described_class.call(:super_admin, %i[very deep nested action])).to be true
    end

    it 'returns false for super_looser' do
      expect(described_class.call(:super_looser, %i[action])).to be false
      expect(described_class.call(:super_looser, %i[nested action])).to be false
      expect(described_class.call(:super_looser, %i[deep nested action])).to be false
      expect(described_class.call(:super_looser, %i[very deep nested action])).to be false
    end

    context 'when admin', role: :admin do
      it 'returns true for existed action', resources: %i[orders], action: :create do
        expect(response).to be true
      end

      it 'returns false for existed action', resources: %i[products], action: :create do
        expect(response).to be false
      end

      it 'returns false for non existed action', resources: %i[products computers], action: :create do
        expect(response).to be false
      end
    end

    context 'when super_admin', role: :super_admin do
      it 'returns true for existed action', resources: %i[orders], action: :create do
        expect(response).to be true
      end

      it 'returns true for existed action', resources: %i[products], action: :create do
        expect(response).to be true
      end

      it 'returns nil for non existed action', resources: %i[products computers], action: :create do
        expect(response).to be true
      end
    end

    context 'when super_looser', role: :super_looser do
      it 'returns false for existed action', resources: %i[orders], action: :create do
        expect(response).to be false
      end

      it 'returns false for existed action', resources: %i[products], action: :create do
        expect(response).to be false
      end

      it 'returns false for non existed action', resources: %i[products computers], action: :create do
        expect(response).to be false
      end
    end

    context 'when medium_looser', role: :medium_looser do
      it 'returns true for existed action', action: :create do
        expect(response).to be true
      end

      it 'returns false for existed action', action: :delete do
        expect(response).to be false
      end

      it 'returns true for non existed key', resources: %i[products computers], action: :create do
        expect(response).to be true
      end
    end

    context 'with personal policy_hash' do
      subject(:response) do |ex|
        described_class.call(ex.metadata[:role], [ex.metadata[:resource], ex.metadata[:action]], policy_hash: policy_hash)
      end
      let(:policy_hash) do
        {
          custom_role: {
            my_custom_resource: {
              read: true,
              create: false,
              update: true,
              delete: false
            }
          }
        }
      end
      context 'for my_custom_resource', resource: :my_custom_resource do
        context 'when admin', role: :custom_role do
          it('returns true for orders read', action: :read) { expect(response).to be true }
          it('returns true for orders create', action: :create) { expect(response).to be false }
          it('returns true for orders update', action: :update) { expect(response).to be true }
          it('returns true for orders delete', action: :delete) { expect(response).to be false }
        end

        context 'when admin', role: :other_custom_role do
          it('returns true for orders read', action: :read) { expect(response).to be false }
          it('returns true for orders create', action: :create) { expect(response).to be false }
          it('returns true for orders update', action: :update) { expect(response).to be false }
          it('returns true for orders delete', action: :delete) { expect(response).to be false }
        end
      end

      context 'for not my_resource', resource: :not_my_resource do
        context 'when admin', role: :custom_role do
          it('returns true for orders read', action: :read) { expect(response).to be false }
          it('returns true for orders create', action: :create) { expect(response).to be false }
          it('returns true for orders update', action: :update) { expect(response).to be false }
          it('returns true for orders delete', action: :delete) { expect(response).to be false }
        end

        context 'when admin', role: :other_custom_role do
          it('returns true for orders read', action: :read) { expect(response).to be false }
          it('returns true for orders create', action: :create) { expect(response).to be false }
          it('returns true for orders update', action: :update) { expect(response).to be false }
          it('returns true for orders delete', action: :delete) { expect(response).to be false }
        end
      end
    end
  end


  context "with 'maybe' value" do
    subject(:response) do |ex|
      described_class.call(ex.metadata[:role], [ex.metadata[:resource], :update])
    end

    context 'for allowed resource', resource: :bookings do
      context 'when admin', role: :admin do
        it('returns true') { expect(response).to be true }
      end
    end

    context 'for maybe allowed resource', resource: :bookings do
      context 'when manager', role: :manager do
        context 'when block is present' do
          context 'when positive condition' do
            it('returns true') do
              expect(described_class.call(:manager, [:bookings, :update]) { 'true' == 'true' }).to be true
            end
          end

          context 'when negative condition' do
            it('returns false') do
              expect(described_class.call(:manager, [:bookings, :update]) { 'true' == 'false' }).to be false
            end
          end
        end

        context 'when block is NOT present' do
          context 'when positive condition' do
            it('raises an error') do
              expect { described_class.call(:manager, [:bookings, :update]) }.to raise_error(Passpartu::BlockVerify::BlockMissedError, "Block is required for 'maybe' allowed resource")
            end
          end

          context 'when negative condition' do
            it('raises an error') do
              expect { described_class.call(:manager, [:bookings, :update]) }.to raise_error(Passpartu::BlockVerify::BlockMissedError, "Block is required for 'maybe' allowed resource")
            end
          end
        end
      end
    end

    context 'for not allowed resource', resource: :bookings do
      context 'when admin', role: :medium_looser do
        it('returns true') { expect(response).to be false }
      end
    end
  end
end
