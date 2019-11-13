module Passpartu
  class Waterfall
    def initialize(keys)
      @keys = keys
    end

    def self.call(keys)
      new(keys).call
    end

    def call
      loop_hash = policy_hash.dup
      keys.each do |key|
        if loop_hash[key].is_a? Hash
          loop_hash = loop_hash[key]
          next
        else
          @result = loop_hash[key]
        end
        break
      end
      @result
    end

    private

    attr_reader :keys, :result

    def policy_hash
      @policy_hash ||= Passpartu.policy
    end
  end
end
