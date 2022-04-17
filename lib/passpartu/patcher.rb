# frozen_string_literal: true

module Passpartu
  class Patcher
    attr_reader :klass

    def initialize(klass)
      raise PolicyYmlNotFoundError if Passpartu.policy.nil?

      @klass = klass
    end

    def self.call(klass)
      new(klass).call
    end

    def call
      klass.class_eval do
        # before_save :update_policy_hash if defined? :before_save

        define_method(:can?) do |*keys, only: nil, except: nil, skip: nil, &block|
          p_hash = respond_to?(:policy_hash) ? nil : Passpartu.policy
          Passpartu::BlockVerify.call(role, keys, only: only, except: except, skip: skip, policy_hash: p_hash, &block)
        end

        Passpartu.policy.each_key do |policy_role|
          define_method("#{policy_role}_can?") do |*keys, only: nil, except: nil, skip: nil, &block|
            role.to_s == policy_role && Passpartu::BlockVerify.call(role, keys,
                                                                    only: only,
                                                                    except: except,
                                                                    skip: skip,
                                                                    &block)
          end
        end

        # def update_policy_hash
        #   return unless respond_to?(:policy_hash) && respond_to?(:policy_hash=)
        #
        #   self.policy_hash = Passpartu.policy.slice(role.to_s)
        # end
      end
    end
  end
end
