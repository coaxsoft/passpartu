require 'doorman/version'
require 'yaml'
require_relative 'doorman/patcher'
require_relative 'doorman/verify'
require_relative 'doorman/validate_result'
require_relative 'doorman/user' # for testing only

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
    attr_accessor :policy_file, :policy, :raise_policy_missed_error, :policy_class, :policy_class_name

    def initialize
      @policy_file = './config/doorman.yml'
      @policy = YAML.load_file(policy_file)
      @raise_policy_missed_error = true
      @policy_class_name = 'User'
    end

    def policy_file=(file = nil)
      @policy_file = file || './config/doorman.yml'
      @policy = YAML.load_file(policy_file)
    end

    def policy_class_name=(name)
      @policy_class_name = name
      @policy_class = eval(@policy_class_name)
      Doorman::Patcher.call(Doorman.config.policy_class)
    end
  end

  configure {}

  Doorman::Patcher.call(Doorman.config.policy_class)
end

initializer = './config/initializers/doorman.rb'
require initializer if File.exist?(initializer)
