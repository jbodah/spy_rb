require 'test_helper'

class SmokeTest < Minitest::Spec
  after do
    Spy.restore(:all)
  end

  it 'raises already spied error properly' do
    klass = Class.new(Object)
    assert_raises Spy::Errors::AlreadySpiedError do
      Spy.on(klass, :to_s)
      Spy.on(klass, :to_s)
    end
  end

  it 'cleans up after already spied errors' do
    klass = Class.new(Object)
    assert_raises Spy::Errors::AlreadySpiedError do
      Spy.on(klass, :to_s)
      Spy.on(klass, :to_s)
    end
    assert Spy.send(:core).send(:collection).instance_variable_get(:@store).count == 1
  end
end
