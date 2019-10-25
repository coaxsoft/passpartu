# frozen_string_literal: true

module Passpartu
  module Initializer
    HOME_PATH = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    CONFIG_FILE_TEMPLATE = File.join(HOME_PATH, 'config', 'passpartu_template.yml')
    INITITALIZER_FILE_TEMPLATE = File.join(HOME_PATH, 'config', 'initializers', 'passpartu.rb')
    DEFAULT_CONFIG_FILE_PATH = './config/passpartu.yml'
    DEFAULT_INITIALIZER_PATH = './config/initializers/passpartu.rb'

    def check_or_create_defaults(policy_file)
      File.file?(policy_file) || clone_file(DEFAULT_CONFIG_FILE_PATH, CONFIG_FILE_TEMPLATE)
      File.file?(DEFAULT_INITIALIZER_PATH) || clone_file(DEFAULT_INITIALIZER_PATH, INITITALIZER_FILE_TEMPLATE)
    end

    private

    def clone_file(destination, source)
      File.write(destination, File.read(source))
    end
  end
end
