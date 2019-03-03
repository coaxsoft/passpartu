module Passpartu
  class Verify
    attr_reader :role, :keys
    def initialize(role, keys)
      @role = role
      @keys = keys.map(&:to_s)
    end

    def self.call(role, keys)
      new(role, keys).call
    end

    def call
      Passpartu::ValidateResult.call(Passpartu.policy.dig(role.to_s, *keys))
    end
  end
end
