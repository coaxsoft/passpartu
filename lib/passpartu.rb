# frozen_string_literal: true

require 'passpartu/version'
require 'yaml'
require_relative 'passpartu/patcher'
require_relative 'passpartu/verify'
require_relative 'passpartu/block_verify'
require_relative 'passpartu/validate_result'
require_relative 'passpartu/test_user' # for testing only

module Passpartu
  class Error < StandardError; end
  class PolicyYmlNotFoundError < StandardError; end
  class WaterfallError < StandardError; end

  class << self
    attr_accessor :config

    def included(policy_class)
      Passpartu::Patcher.call(policy_class)
    end

    def policy
      config.policy
    end

    def configure
      self.config ||= Config.new
      yield(config)
    end
  end

  class Config
    attr_accessor :raise_policy_missed_error, :role_access_method
    attr_reader :policy_file, :check_waterfall, :policy

    DEFAULT_POLICY_FILE = './config/passpartu.yml'

    def initialize
      @policy_file = DEFAULT_POLICY_FILE
      self.policy = load_policy_file(policy_file) if File.exist?(policy_file)
      @raise_policy_missed_error = true
      @check_waterfall = false
      @role_access_method = :role
    end

    def policy_file=(file = nil)
      @policy_file = file || DEFAULT_POLICY_FILE

      raise PolicyYmlNotFoundError unless File.exist?(policy_file)

      self.policy = load_policy_file(policy_file)
    end

    def check_waterfall=(value)
      @check_waterfall = value

      @check_waterfall.tap do |check_waterfall|
        if check_waterfall
          @raise_policy_missed_error = false
          self.policy = @policy
        end
      end
    end

    private

    def load_policy_file(path)
      RUBY_VERSION.to_f >= 3.1 ? YAML.load_file(path, aliases: true) : YAML.load_file(path)
    end

    def policy=(value)
      @policy = patch_policy_booleans_if(value)
    end

    # patch all booleans in hash to support check_waterfall
    def patch_policy_booleans_if(hash)
      return hash unless @check_waterfall

      hash.transform_values! do |value|
        case value
        when true
          value.define_singleton_method(:dig) { |*_keys| true }
        when false
          value.define_singleton_method(:dig) { |*_keys| false }
        when 'maybe'
          value.define_singleton_method(:dig) { |*_keys| 'maybe' }
        else
          patch_policy_booleans_if(value)
        end

        value
      end
    end

    def blank?(item)
      item.respond_to?(:empty?) ? !!item.empty? : !item
    end

    def present?(item)
      !blank?(item)
    end
  end
end

initializer = './config/initializers/passpartu.rb'
require initializer if File.exist?(initializer)
