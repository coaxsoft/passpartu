module Passpartu
  class Verify
    CRUD_KEY = 'crud'.freeze

    attr_reader :role, :keys, :result, :except, :block
    def initialize(role, keys, except, skip, block)
      exclusion = except || skip # alias

      @role = role.to_s
      @keys = keys.map(&:to_s)
      @except = Array(exclusion).map(&:to_s) if present?(exclusion)
      @block = block
    end

    def self.call(role, keys, except: nil, skip: nil, &block)
      new(role, keys, except, skip, block).call
    end

    def call
      return false if role_excepted?

      check_policy
      check_crud if policy_missed? && last_key_crud?

      validate_result
    end

    private

    def role_excepted?
      return false if blank?(except)

      except.include?(role)
    end

    def check_policy
      @result = Passpartu.policy.dig(role, *keys)
    end

    def check_crud
      change_crud_key
      check_policy
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

    def last_key_crud?
      %w[create read update delete].include?(keys[-1])
    end

    def blank?(item)
      item.respond_to?(:empty?) ? !!item.empty? : !item
    end

    def present?(item)
      !blank?(item)
    end
  end
end
