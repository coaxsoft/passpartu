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

      if hash_include_keys?(policy_hash, role_and_keys)
        check_policy
      elsif policy_missed? && last_key_crud?
        check_crud
      end
      check_waterfall if policy_missed?

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
      @role_and_keys ||= [role] + keys
    end

    def check_policy
      @result = Passpartu.policy.dig(role, *keys)
    end

    def check_crud
      change_crud_key
      check_policy if hash_include_keys?(policy_hash, [role] + keys)
    end

    def check_waterfall
      keys = role_and_keys.clone
      loop do
        keys.pop
        @result = hash_include_keys?(policy_hash, keys) ? policy_hash.dig(*keys) : nil
        break if @result || keys.empty?
      end
    end

    def hash_include_keys?(hash, keys)
      flatten_hash(hash).keys.any? { |k| k.include?(keys.join('_')) }
    end

    def flatten_hash(hash)
      hash.each_with_object({}) do |(k, v), h|
        if v.is_a? Hash
          flatten_hash(v).map do |h_k, h_v|
            h["#{k}_#{h_k}"] = h_v
          end
        else
          h[k] = v
        end
      end
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
