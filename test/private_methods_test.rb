require 'test_helper'

class PrivateMethodsTest < Minitest::Spec
  it 'private methods can be spied on' do
    klass = Class.new do
      private

      def name
        "penny"
      end
    end

    obj = klass.new

    # Bad
    assert_raises ArgumentError do
      Spy.on(obj, :name)
    end

    # Good
    Spy.on(obj, :name, allow_private: true)

    # Bad
    assert_raises ArgumentError do
      Spy.on_any_instance(klass, :name)
    end

    # Good
    Spy.on_any_instance(klass, :name, allow_private: true)
  end

  it 'protected methods can be spied on' do
    klass = Class.new do
      protected

      def name
        "penny"
      end
    end

    obj = klass.new

    # Bad
    assert_raises ArgumentError do
      Spy.on(obj, :name)
    end

    # Good
    Spy.on(obj, :name, allow_private: true)

    # Bad
    assert_raises ArgumentError do
      Spy.on_any_instance(klass, :name)
    end

    # Good
    Spy.on_any_instance(klass, :name, allow_private: true)
  end
end

