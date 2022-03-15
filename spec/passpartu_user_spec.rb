# frozen_string_literal: true

class User
  include Passpartu
end

RSpec.describe Passpartu do
  describe 'included' do
    it 'response to can? method' do
      expect(User.new.respond_to?(:can?)).to be true
    end
  end
end
