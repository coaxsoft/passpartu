# frozen_string_literal: true

# this is example of initializer
# this file is required for gem's test cases

Passpartu.configure do |config|
  # config.policy_file = './config/passpartu_custom.yml'
  # config.raise_policy_missed_error = true
end
# Passpartu.config.ensure_policy checks if policy files are present and valid
# and creates default config file if not present
Passpartu.config.ensure_policy
