require 'test_helper'

class InsteadTest < Minitest::Spec
  describe 'Spy::Instance#instead' do
    after do
      Spy.restore(:all)
    end

    it 'will run the instead block and not the original call' do
      o = Object.new
      o.instance_eval do
        def incr; total += 1; end
        def total; @total ||= 0; end
        def total=(n); @total = n; end
      end

      Spy.on(o, :incr).instead do |mc|
        mc.receiver.total += 2
      end

      o.incr

      assert_equal 2, o.total
    end

    it 'will return the value returned by the block' do
      o = Object.new
      o.instance_eval do
        def name; 'josh'; end
      end

      Spy.on(o, :name).instead { 'penny' }

      assert_equal 'penny', o.name
    end

    it 'plays nicely with Spy::Instance#when' do
      o = Object.new
      o.instance_eval do
        def value=(n); @value = n; end
        def value; @value; end
        def name; 'josh'; end
      end

      Spy.on(o, :name).when { o.value == 0 }.instead { 'penny' }

      o.value = 0
      assert_equal 'penny', o.name

      o.value = 1
      assert_equal 'josh', o.name
    end

    it 'allows multiple whens and insteads' do
      skip 'havent implemented multiple whens yet'

      o = Object.new
      o.instance_eval do
        def value=(n); @value = n; end
        def value; @value; end
        def name; 'josh'; end
      end

      Spy.on(o, :name).when { o.value == 0 }.instead { 'penny' }
      Spy.on(o, :name).when { o.value == 1 }.instead { 'lauren' }

      o.value = 0
      assert_equal 'penny', o.name

      o.value = 1
      assert_equal 'lauren', o.name
    end
  end
end
