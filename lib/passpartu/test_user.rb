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

  class TestUserWithOtherRoleMethod
    attr_reader :other_role_method

    def initialize(role)
      @other_role_method = role
    end
  end
end
