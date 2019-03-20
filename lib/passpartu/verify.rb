module Passpartu
  class Verify
    CRUD_KEY = 'crud'.freeze

    attr_reader :role, :keys, :result, :except
    def initialize(role, keys, except)
      @role = role.to_s
      @keys = keys.map(&:to_s)
      @except = Array(except).map(&:to_s) if present?(except)
    end

    def self.call(role, keys, except: nil)
      new(role, keys, except).call
    end

    def call
      return false if role_excepted?

      check
      check_crud if policy_missed? && last_key_crud?

      validate_result
    end

    private

    def role_excepted?
      return false if blank?(except)

      except.include?(role)
    end

    def check
      @result = Passpartu.policy.dig(role, *keys)
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
