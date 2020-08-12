# frozen_string_literal: true

require 'passpartu/version'
require 'yaml'
require_relative 'passpartu/patcher'
require_relative 'passpartu/verify'
require_relative 'passpartu/block_verify'
require_relative 'passpartu/validate_result'
require_relative 'passpartu/user' # for testing only

module Passpartu
  class Error < StandardError; end
  class PolicyYmlNotFoundError < StandardError; end
  class WaterfallError < StandardError; end

  def self.included(policy_class)
    Passpartu::Patcher.call(policy_class)
  end

  def self.policy
    config.policy
  end

  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Config.new
    yield(config)
  end

  class Config
    attr_accessor :raise_policy_missed_error
    attr_reader :policy_file, :check_waterfall, :policy

    DEFAULT_POLICY_FILE = './config/passpartu.yml'

    def initialize
      @policy_file = DEFAULT_POLICY_FILE
      set_policy(YAML.load_file(policy_file)) if File.exist?(policy_file)
      @raise_policy_missed_error = true
      @check_waterfall = false
    end

    def policy_file=(file = nil)
      @policy_file = file || DEFAULT_POLICY_FILE

      raise PolicyYmlNotFoundError unless File.exist?(policy_file)

      set_policy(YAML.load_file(policy_file))
    end

    def check_waterfall=(value)
      @check_waterfall = value

      if @check_waterfall
        @raise_policy_missed_error = false
        set_policy(@policy)
      end

      @check_waterfall
    end

    private

    def set_policy(value)
      @policy = patch_policy_booleans_if(value)
    end

    # patch all booleans in hash to support check_waterfall
    def patch_policy_booleans_if(hash)
      return hash unless @check_waterfall

      hash.transform_values! do |value|
        if value.is_a?(TrueClass)
          value.define_singleton_method(:dig) { |*_keys| true }
        elsif value.is_a?(FalseClass)
          value.define_singleton_method(:dig) { |*_keys| false }
        elsif
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

  configure {}
end

initializer = './config/initializers/passpartu.rb'
require initializer if File.exist?(initializer)
