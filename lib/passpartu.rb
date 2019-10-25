# frozen_string_literal: true

require 'passpartu/version'
require 'yaml'
require_relative 'passpartu/patcher'
require_relative 'passpartu/verify'
require_relative 'passpartu/block_verify'
require_relative 'passpartu/validate_result'
require_relative 'passpartu/user' # for testing only
require_relative 'passpartu/initializer'

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
    include Passpartu::Initializer

    attr_accessor :policy, :raise_policy_missed_error
    attr_reader :policy_file, :use_custom_config_file

    def initialize
      @policy_file = DEFAULT_CONFIG_FILE_PATH
      check_or_create_defaults(@policy_file) unless @use_custom_config_file
      @policy = YAML.load_file(policy_file)
      @raise_policy_missed_error = true
      @use_custom_config_file = false
    end

    def policy_file=(file = nil)
      @use_custom_config_file = File.file?(file)
      @policy_file = file || DEFAULT_CONFIG_FILE_PATH
      @policy = YAML.load_file(policy_file)
    end

    def validate_policy
      raise wrong_config_error unless policy.is_a?(Hash)
    end

    private

    def wrong_config_error
      <<-ERROR

        ************************************************************************************
        !!! Passpartu is not configured properly. Check configuration file: #{@policy_file}
        :: Configuration example: https://github.com/coaxsoft/passpartu#real-life-example ::
        ************************************************************************************
      ERROR
    end
  end

  configure {}
end

require Passpartu::Initializer::DEFAULT_INITIALIZER_PATH
Passpartu.config.validate_policy
