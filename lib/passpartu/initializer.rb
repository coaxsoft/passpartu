# frozen_string_literal: true

module Passpartu
  module Initializer
    HOME_PATH = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    CONFIG_FILE_TEMPLATE = File.join(HOME_PATH, 'config', 'passpartu_template.yml')
    INITITALIZER_FILE_TEMPALTE = File.join(HOME_PATH, 'config', 'initializers', 'passpartu.rb')
    DEFAULT_CONFIG_FILE_PATH = './config/passpartu.yml'
    DEFAULT_INITIALIZER_PATH = './config/initializers/passpartu.rb'

    def check_or_create_defaults(policy_file)
      File.write(DEFAULT_CONFIG_FILE_PATH, File.read(CONFIG_FILE_TEMPLATE)) unless File.file?(policy_file)
      unless File.file?(Passpartu::Initializer::DEFAULT_INITIALIZER_PATH)
        File.write(Passpartu::Initializer::DEFAULT_INITIALIZER_PATH, File.read(Passpartu::Initializer::INITITALIZER_FILE_TEMPALTE))
      end
    end
  end
end
