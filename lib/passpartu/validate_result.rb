# frozen_string_literal: true

module Passpartu
  class ValidateResult
    class PolicyMissedError < StandardError; end
    class InvalidResultError < StandardError; end

    attr_reader :result

    def initialize(result)
      @result = result
    end

    def self.call(result)
      new(result).call
    end

    def call
      raise PolicyMissedError if raise_policy_missed_error?
      return false if result_not_defined?

      result
    end

    private

    def raise_policy_missed_error?
      result_not_defined? && Passpartu.config.raise_policy_missed_error
    end

    def result_not_defined?
      result.nil? || result.is_a?(Hash)
    end
  end
end
