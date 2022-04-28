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
      phash = respond_to?(:policy_hash) ? {} : Passpartu.policy
      role_method = Passpartu.config.role_access_method

      klass.class_eval do
        define_method(:can?) do |*keys, only: nil, except: nil, skip: nil, &block|
          Passpartu::BlockVerify.call(
            send(role_method),
            keys,
            only: only,
            except: except,
            skip: skip,
            policy_hash: phash,
            &block
          )
        end

        phash.each_key do |policy_role|
          define_method("#{policy_role}_can?") do |*keys, only: nil, except: nil, skip: nil, &block|
            send(role_method).to_s == policy_role &&
              Passpartu::BlockVerify.call(
                send(role_method),
                keys,
                only: only,
                except: except,
                skip: skip,
                policy_hash: phash,
                &block
              )
          end
        end
      end
    end
  end
end
