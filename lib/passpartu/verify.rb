module Passpartu
  class Verify
    CRUD_KEY = 'crud'.freeze

    attr_reader :role, :keys, :result
    def initialize(role, keys)
      @role = role
      @keys = keys.map(&:to_s)
    end

    def self.call(role, keys)
      new(role, keys).call
    end

    def call
      check
      check_crud if policy_missed?

      validate_result
    end

    private

    def check
      @result = Passpartu.policy.dig(role.to_s, *keys)
    end

    def check_crud
      change_crud_key
      check
    end

    def change_crud_key
      @keys[-1] = CRUD_KEY
    end

    def policy_missed?
      @result.nil?
    end

    def validate_result
      Passpartu::ValidateResult.call(result)
    end
  end
end
