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
    attr_reader :policy_file, :use_custom_config_file
    PASSPARTU_HOME = File.realpath(File.join(File.dirname(__FILE__), '..'))
    PASSPARTU_CONFIG_TEMPLATE = File.join(PASSPARTU_HOME, 'config', 'passpartu_template.yml')
    PASSPARTU_INITIALIZER_TEMPLATE = File.join(PASSPARTU_HOME, 'config', 'initializers', 'passpartu.rb')
    APP_CONFIG_FILE_PATH = './config/passpartu.yml'
    APP_INITIALIZER_PATH = './config/initializers/passpartu.rb'

    def initialize
      @policy_file = APP_CONFIG_FILE_PATH
      create_default_config_file unless @use_custom_config_file || File.file?(policy_file)
      @policy = YAML.load_file(policy_file)
      @raise_policy_missed_error = true
      @use_custom_config_file = false
    end

    def policy_file=(file = nil)
      @use_custom_config_file = File.file?(file)
      @policy_file = file || APP_CONFIG_FILE_PATH
      @policy = YAML.load_file(policy_file)

      raise wrong_config_error unless @policy.present?
    end

    def wrong_config_error
      <<-ERROR

        ************************************************************************************
        !!! Passpartu is not configured properly. Check configuration file: #{@policy_file}
        :: Configuration example: https://github.com/coaxsoft/passpartu#real-life-example ::
        ************************************************************************************
      ERROR
    end

    private

    def create_default_config_file
      File.write(APP_CONFIG_FILE_PATH, File.read(PASSPARTU_CONFIG_TEMPLATE))
    end
  end

  configure {}
end

unless File.file?(Passpartu::Config::APP_INITIALIZER_PATH)
  File.write(Passpartu::Config::APP_INITIALIZER_PATH, File.read(Passpartu::Config::PASSPARTU_INITIALIZER_TEMPLATE))
end
require Passpartu::Config::APP_INITIALIZER_PATH
