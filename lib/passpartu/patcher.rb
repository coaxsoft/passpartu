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
        define_method('can?') do |*keys|
          Passpartu::Verify.call(role, keys)
        end
      end
    end
  end
end
