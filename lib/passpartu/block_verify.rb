module Passpartu
  class BlockVerify < ::Passpartu::Verify
    def call
      policy_result = super
      return policy_result if block.nil?

      policy_result && block.call
    end
  end
end
