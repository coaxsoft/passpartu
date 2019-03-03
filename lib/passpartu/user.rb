# for testing only

module Passpartu
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
