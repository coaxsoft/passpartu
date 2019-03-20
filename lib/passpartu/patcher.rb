module Passpartu
  class Patcher
    attr_reader :klass
    def initialize(klass)
      @klass = klass
    end

    def self.call(klass)
      new(klass).call
    end

    def call
      klass.class_eval do
        define_method('can?') do |*keys, except: nil, &block|
          Passpartu::BlockVerify.call(role, keys, except: except, &block)
        end

        Passpartu.policy.keys.each do |policy_role|
          define_method("#{policy_role}_can?") do |*keys, except: nil, &block|
            role.to_s == policy_role && Passpartu::BlockVerify.call(role, keys, except: except, &block)
          end
        end
      end
    end
  end
end
