module Passpartu
  class Verify
    attr_reader :role, :keys, :result, :only, :except, :block

    def initialize(role, keys, only, except, skip, block)
      exclusion = except || skip # alias

      @role = role.to_s
      @keys = keys.map(&:to_s)
      @only = Array(only).map(&:to_s) if present?(only)
      @except = Array(exclusion).map(&:to_s) if present?(exclusion) && !@only
      @block = block
    end

    def self.call(role, keys, only: nil, except: nil, skip: nil, &block)
      new(role, keys, only, except, skip, block).call
    end

    def call
      return false if role_ignore?

      @result = Passpartu::CheckPolicy.call(role_and_keys)
      validate_result
    end

    private

    def role_ignore?
      return !only.include?(role) if present?(only)
      return except.include?(role) if present?(except)

      false
    end

    def role_and_keys
      [role] + keys
    end

    def validate_result
      Passpartu::ValidateResult.call(result)
    end

    def blank?(item)
      item.respond_to?(:empty?) ? !!item.empty? : !item
    end

    def present?(item)
      !blank?(item)
    end
  end
end
