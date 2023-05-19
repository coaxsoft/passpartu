# frozen_string_literal: true

module Passpartu
  class BlockVerify < ::Passpartu::Verify
    class BlockMissedError < StandardError; end
    MAYBE_VALUE = 'maybe'

    def call
      policy_result = super
      raise BlockMissedError, "Block is required for 'maybe' allowed resource" if maybe? && block.nil?
      return policy_result if block.nil?

      policy_result && block.call
    end

    private

    def maybe?
      result == MAYBE_VALUE
    end
  end
end
