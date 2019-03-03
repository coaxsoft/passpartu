require 'doorman/version'
require 'yaml'
require 'byebug'
require_relative 'doorman/helpers'
require_relative 'doorman/patcher'
require_relative 'doorman/verify'
require_relative 'doorman/validate_result'
require_relative 'doorman/user' # for testing only

# for stubbing
unless defined?(::User)
  class User
  end
end

module Doorman
  class Error < StandardError; end

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
    include ::Doorman::Helpers
    attr_accessor :policy, :raise_policy_missed_error, :policy_class
    attr_reader :policy_file, :policy_class_name

    def initialize
      @policy_file = './config/doorman.yml'
      @policy = YAML.load_file(policy_file)
      @raise_policy_missed_error = true
      @policy_class_name = '::User'
      @policy_class = constantize(@policy_class_name)
    end

    def policy_file=(file = nil)
      @policy_file = file || './config/doorman.yml'
      @policy = YAML.load_file(policy_file)
    end

    def policy_class_name=(name)
      @policy_class_name = name
      @policy_class = constantize(@policy_class_name)
      Doorman::Patcher.call(Doorman.config.policy_class)
    end
  end

  configure {}

  Doorman::Patcher.call(Doorman.config.policy_class)
end

initializer = './config/initializers/doorman.rb'
require initializer if File.exist?(initializer)
