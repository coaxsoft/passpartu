class User
  include Passpartu
end

RSpec.describe Passpartu do
  describe 'included' do
    it 'should response to can? method' do
      expect(User.new.respond_to?(:can?)).to eq true
    end
  end
end
