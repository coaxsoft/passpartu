RSpec.describe Passpartu::Patcher do
  describe '#call' do
    let(:policy_class) { Passpartu::User }
    it 'add method can? to policy_class' do
      described_class.call(policy_class)

      expect(policy_class.new('admin').respond_to?(:can?)).to eq true
    end

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
end
