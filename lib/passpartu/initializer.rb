# frozen_string_literal: true

module Passpartu
  module Initializer
    HOME_PATH = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    CONFIG_FILE_TEMPLATE = File.join(HOME_PATH, 'config', 'passpartu_template.yml')
    INITIALIZER_FILE_TEMPLATE = File.join(HOME_PATH, 'config', 'initializers', 'passpartu.rb')
    DEFAULT_CONFIG_FOLDER_PATH = './config'
    DEFAULT_INITIALIZER_FOLDER_PATH = './config/initializers'
    DEFAULT_CONFIG_FILE_PATH = File.join(DEFAULT_CONFIG_FOLDER_PATH, 'passpartu.yml')
    DEFAULT_INITIALIZER_PATH = File.join(DEFAULT_INITIALIZER_FOLDER_PATH, 'passpartu.rb')

    def check_or_create_defaults(policy_file)
      mkdirs_if_not_exists DEFAULT_CONFIG_FOLDER_PATH, DEFAULT_INITIALIZER_FOLDER_PATH
      File.file?(policy_file) || clone_file(DEFAULT_CONFIG_FILE_PATH, CONFIG_FILE_TEMPLATE)
      File.file?(DEFAULT_INITIALIZER_PATH) || clone_file(DEFAULT_INITIALIZER_PATH, INITIALIZER_FILE_TEMPLATE)
    end

    def validate_policy
      raise wrong_config_error unless policy.is_a?(Hash)
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

    def mkdirs_if_not_exists(*dir_names)
      dir_names.each do |name|
        Dir.mkdir(name) unless Dir.exist?(name)
      end
    end

    def clone_file(destination, source)
      File.write(destination, File.read(source))
    end
  end
end
