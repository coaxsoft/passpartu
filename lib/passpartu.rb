require 'passpartu/version'
require 'yaml'
require_relative 'passpartu/patcher'
require_relative 'passpartu/verify'
require_relative 'passpartu/block_verify'
require_relative 'passpartu/validate_result'
require_relative 'passpartu/check_waterfall'
require_relative 'passpartu/user' # for testing only

module Passpartu
  class Error < StandardError; end
  class PolicyYmlNotFoundError < StandardError; end

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
    attr_accessor :policy, :raise_policy_missed_error, :check_waterfall
    attr_reader :policy_file

    DEFAULT_POLICY_FILE = './config/passpartu.yml'.freeze

    def initialize
      @policy_file = DEFAULT_POLICY_FILE
      @policy = YAML.load_file(policy_file) if File.exists?(policy_file)
      @raise_policy_missed_error = true
      @check_waterfall = false
    end

    def policy_file=(file = nil)
      @policy_file = file || DEFAULT_POLICY_FILE

      raise PolicyYmlNotFoundError unless File.exists?(policy_file)

      @policy = YAML.load_file(policy_file)
    end
  end

  configure {}
end

initializer = './config/initializers/passpartu.rb'
require initializer if File.exist?(initializer)
