# for testing only

module Doorman
  class User
    attr_reader :role

    def initialize(role)
      @role = role
    end
  end

  class Person
    attr_reader :role

    def initialize(role)
      @role = role
    end
  end
end
