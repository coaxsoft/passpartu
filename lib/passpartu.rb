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

    attr_accessor :raise_policy_missed_error
    attr_reader :policy_file, :use_custom_config_file

    def initialize
      @policy_file ||= DEFAULT_CONFIG_FILE_PATH
      @raise_policy_missed_error = true
      @use_custom_config_file = false
    end

    def policy_file=(file = nil)
      @use_custom_config_file = file != DEFAULT_CONFIG_FILE_PATH && File.file?(file)
      @policy_file = file || DEFAULT_CONFIG_FILE_PATH
    end

    def policy
      @policy ||= YAML.load_file(policy_file)
    rescue Errno::ENOENT
      nil
    end

    def ensure_policy
      if policy.nil? && !use_custom_config_file
        check_or_create_defaults(policy_file)
      end

      validate_policy
    end
  end

  configure {}
end

require Passpartu::Initializer::DEFAULT_INITIALIZER_PATH
