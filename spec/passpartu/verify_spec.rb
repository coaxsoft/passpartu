RSpec.describe Passpartu::Verify do
  describe '#call' do
    let(:policy_class) { Passpartu.config.policy_class }

    before do
      Passpartu.config.raise_policy_missed_error = true
    end

    context 'waterfall_rules default(false)' do
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

    context 'waterfall_rules true' do
      before do
        Passpartu.config.waterfall_rules = true
      end

      context 'for maanger' do
        let(:role) { 'manager' }

        it 'returns true for payments whatever' do
          expect(described_class.call(role, %i[payments whatever])).to eq true
        end
      end

      context 'for super_admin' do
        let(:role) { 'super_admin' }

        it 'returns true for orders create' do
          expect(described_class.call(role, %i[orders create])).to eq true
        end
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

          context 'misspelled' do
            context 'raise policy_missed_error true' do
              it 'raises an error if its not crud action' do
                expect { described_class.call(role, %i[items crea]) }.to raise_error Passpartu::ValidateResult::PolicyMissedError
              end

              it 'raises an error if its not crud action' do
                expect { described_class.call(role, %i[items rea]) }.to raise_error Passpartu::ValidateResult::PolicyMissedError
              end

              it 'raises an error if its not crud action' do
                expect { described_class.call(role, %i[items upde]) }.to raise_error Passpartu::ValidateResult::PolicyMissedError
              end

              it 'raises an error if its not crud action' do
                expect { described_class.call(role, %i[items dele]) }.to raise_error Passpartu::ValidateResult::PolicyMissedError
              end
            end

            context 'raise policy_missed_error false' do
              before(:each) do
                Passpartu.config.raise_policy_missed_error = false
              end

              it 'returns false for orders create' do
                expect(described_class.call(role, %i[items crea])).to eq false
              end

              it 'returns false for orders read' do
                expect(described_class.call(role, %i[items rea])).to eq false
              end

              it 'returns false for orders update' do
                expect(described_class.call(role, %i[items upde])).to eq false
              end

              it 'returns false for orders delete' do
                expect(described_class.call(role, %i[items dele])).to eq false
              end
            end
          end
        end
      end
    end

    context 'expect param' do
      context 'admin' do
        let(:role) { 'admin' }
        let(:except) { :admin }

        it 'returns false for admin and true for manager' do
          expect(described_class.call(role, %i[orders create])).to eq true

          expect(described_class.call(role, %i[orders create], except: except)).to eq false
          expect(described_class.call(:manager, %i[orders create], except: except)).to eq true
        end
      end

      context 'admin and manger' do
        let(:except) { [:admin, :manager] }

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
        let(:role) { 'admin' }
        let(:only) { :admin }

        it 'returns true for admin and false for manager' do
          expect(described_class.call(role, %i[orders create])).to eq true

          expect(described_class.call(role, %i[orders create], only: only)).to eq true
          expect(described_class.call(:manager, %i[orders create], only: only)).to eq false
        end
      end

      context 'admin and manger' do
        let(:only) { [:admin, :manager] }

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
        let(:role) { 'admin' }
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
end
