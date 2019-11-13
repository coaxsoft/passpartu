module Passpartu
  class CheckPolicy
    CRUD_KEY = 'crud'.freeze

    def initialize(keys)
      @hash = Passpartu.policy
      @keys = keys
      @waterfall_rules = Passpartu.config.waterfall_rules
    end

    def self.call(keys)
      new(keys).call
    end

    def call
      check_policy
      check_crud if policy_missed? && last_key_crud?
      result
    end

    private

    attr_reader :hash, :keys, :waterfall_rules, :result

    def check_policy
      loop_hash = hash.dup
      keys.each_with_index do |key, index|
        if loop_hash[key].is_a? Hash
          loop_hash = loop_hash[key]
          next
        elsif waterfall_rules || last?(index)
          @result = loop_hash[key]
        end
        break
      end
    end

    def check_crud
      change_crud_key
      check_policy
    end

    def change_crud_key
      @keys[-1] = CRUD_KEY
    end

    def last?(index)
      index + 1 == keys.size
    end

    def policy_missed?
      @result.nil?
    end

    def last_key_crud?
      %w[create read update delete].include?(keys[-1])
    end
  end
end
