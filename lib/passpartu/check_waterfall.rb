# frozen_string_literal: true

module Passpartu
  class CheckWaterfall
    attr_reader :waterfall, :policy_hash
    def initialize(role, keys)
      @waterfall = [role] + keys
      @policy_hash = Passpartu.policy
    end

    def self.call(role, keys)
      new(role, keys).call
    end

    def call
      patch_boolean_classes
      @result = policy_hash.dig(*waterfall)
      reset_boolean_classes

      @result
    end

    def patch_boolean_classes
      TrueClass.define_method(:dig) { |*_keys| true }
      FalseClass.define_method(:dig) { |*_keys| false }
    end

    def reset_boolean_classes
      TrueClass.undef_method(:dig)
      FalseClass.undef_method(:dig)
    end
  end
end
