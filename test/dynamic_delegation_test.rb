require 'test_helper'

class DynamicDelegationTest < Minitest::Spec
  class Proxy
    def initialize(delegate)
      @delegate = delegate
    end

    def method_missing(sym, include_all=false)
      @delegate.send(sym)
    end

    def respond_to_missing?(sym, include_all=false)
      sym == :hello
    end
  end

  class TestClass
    def hello
      'hello'
    end
  end

  it 'can be spied' do
    p = Proxy.new(TestClass.new)
    Spy.on(p, :hello)
  end

  it 'has a call history' do
    p = Proxy.new(TestClass.new)
    spy = Spy.on(p, :hello)
    p.hello
    assert spy.call_count == 1
  end

  it 'can be restored' do
    p = Proxy.new(TestClass.new)
    spy = Spy.on(p, :hello)
    Spy.restore(p, :hello, :dynamic_delegation)
    p.hello
    assert spy.call_count == 0
  end
end
