# frozen_string_literal: true

module Passpartu
  class Verify
    CRUD_KEY = 'crud'

    attr_reader :role, :keys, :result, :only, :except, :block

    def initialize(role, keys, only, except, skip, block)
      exclusion = except || skip # alias

      @role = role.to_s
      @keys = keys.map(&:to_s)
      @only = Array(only).map(&:to_s) if present?(only)
      @except = Array(exclusion).map(&:to_s) if present?(exclusion) && !@only
      @block = block

      raise PolicyYmlNotFoundError if Passpartu.policy.nil?
    end

    def self.call(role, keys, only: nil, except: nil, skip: nil, &block)
      new(role, keys, only, except, skip, block).call
    end

    def call
      return false if role_ignore?

      default_check
      check_crud_if

      validate_result
    rescue StandardError => e
      if ['TrueClass does not have #dig method', 'FalseClass does not have #dig method'].include?(e.message)
        raise WaterfallError.new "Looks like you want to use check_waterfall feature, but it's set to 'false'. Otherwise check your #{Passpartu.config.policy_file} for validness"
      else
        raise e
      end
    end

    private

    def role_ignore?
      return !only.include?(role) if present?(only)
      return except.include?(role) if present?(except)

      false
    end

    def default_check
      return unless policy_missed?

      @result = Passpartu.policy.dig(role, *keys)
    end

    def check_crud_if
      return unless policy_missed? && last_key_crud?

      @keys[-1] = CRUD_KEY
      default_check
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
