module Passpartu
  class Verify
    CRUD_KEY = 'crud'.freeze

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

      check_policy
      check_crud if policy_missed? && last_key_crud?

      validate_result
    end

    private

    def role_ignore?
      return !only.include?(role) if present?(only)
      return except.include?(role) if present?(except)

      false
    end

    def policy_hash
      @policy_hash ||= Passpartu.policy
    end

    def role_and_keys
      [role] + keys
    end

    def check_policy
      loop_hash = policy_hash.dup
      role_and_keys.each do |key|
        if loop_hash[key] == true
          @result = true
          break
        elsif loop_hash[key] == false
          @result = false
          break
        elsif loop_hash[key].is_a? Hash
          loop_hash = loop_hash[key]
        else
          break
        end
      end
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
