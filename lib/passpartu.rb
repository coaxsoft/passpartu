require 'passpartu/version'
require 'yaml'
require 'byebug'
require_relative 'passpartu/patcher'
require_relative 'passpartu/verify'
require_relative 'passpartu/validate_result'
require_relative 'passpartu/user' # for testing only

module Passpartu
  class Error < StandardError; end

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
    attr_accessor :policy, :raise_policy_missed_error
    attr_reader :policy_file

    def initialize
      @policy_file = './config/passpartu.yml'
      @policy = YAML.load_file(policy_file)
      @raise_policy_missed_error = true
    end

    def policy_file=(file = nil)
      @policy_file = file || './config/passpartu.yml'
      @policy = YAML.load_file(policy_file)
    end
  end

  configure {}
end

initializer = './config/initializers/passpartu.rb'
require initializer if File.exist?(initializer)
