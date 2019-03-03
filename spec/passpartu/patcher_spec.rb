require 'byebug'

RSpec.describe Passpartu::Patcher do
  describe '#call' do
    let(:policy_class) { Passpartu::User }
    it 'add method can? to policy_class' do
      described_class.call(policy_class)

      expect(policy_class.new('admin').respond_to?(:can?)).to eq true
    end
  end
end
