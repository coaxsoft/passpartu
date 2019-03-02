require 'byebug'

module Doorman
  class Patcher
    attr_reader :klass
    def initialize(klass)
      @klass = klass || User
    end

    def self.call(klass = nil)
      new(klass).call
    end

    def call
      klass.class_eval do
        define_method('can?') do |*keys|
          Doorman::Verify.call(role, keys)
        end
      end
    end
  end
end
