# frozen_string_literal: true

module Passpartu
  class ValidateResult
    class PolicyMissedError < StandardError; end

    attr_reader :result

    def initialize(result)
      @result = result
    end

    def self.call(result)
      new(result).call
    end

    def call
      raise PolicyMissedError if raise_error?
      return false unless boolean?

      result
    end

    private

    def boolean?
      [true, false].include?(result)
    end

    def raise_error?
      !boolean? && Passpartu.config.raise_policy_missed_error
    end
  end
end
