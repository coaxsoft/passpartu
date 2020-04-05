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
      # while true works faster than loop
      while waterfall.size.positive? do
        return reset_boolean_classes && @result if [TrueClass, FalseClass].include?((@result = policy_hash.dig(*waterfall)).class)


        waterfall.pop
      end

      reset_boolean_classes
      nil
    end

    def patch_boolean_classes
      TrueClass.define_method(:dig) { |*keys| true }
      FalseClass.define_method(:dig) { |*keys| false }
    end

    def reset_boolean_classes
      TrueClass.undef_method(:dig)
      FalseClass.undef_method(:dig)
    end
  end
end
