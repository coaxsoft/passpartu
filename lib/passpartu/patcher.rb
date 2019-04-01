# frozen_string_literal: true

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
        define_method('can?') do |*keys, only: nil, except: nil, skip: nil, &block|
          Passpartu::BlockVerify.call(role, keys, only: only, except: except, skip: skip, &block)
        end

        Passpartu.policy.keys.each do |policy_role|
          define_method("#{policy_role}_can?") do |*keys, only: nil, except: nil, skip: nil, &block|
            role.to_s == policy_role && Passpartu::BlockVerify.call(role, keys,
                                                                    only: only,
                                                                    except: except,
                                                                    skip: skip,
                                                                    &block)
          end
        end
      end
    end
  end
end
