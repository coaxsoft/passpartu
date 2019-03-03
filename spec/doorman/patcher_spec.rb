require 'byebug'

RSpec.describe Doorman::Patcher do
  describe '#call' do
    let(:policy_class) { Doorman.config.policy_class }
    it 'add method can? to policy_class' do
      described_class.call(policy_class)

      expect(policy_class.new.respond_to?(:can?)).to eq true
    end
  end
end
