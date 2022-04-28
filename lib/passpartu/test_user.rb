# frozen_string_literal: true

# for testing only

module Passpartu
  class TestUser
    attr_reader :role

    def initialize(role)
      @role = role
    end
  end

  class TestPerson
    attr_reader :role

    def initialize(role)
      @role = role
    end
  end
end
