require 'test_helper'

class MultiTest < Minitest::Spec
  describe '#uncalled' do
    it 'can be used to find unused singleton methods' do
      obj = Object.new
      obj.instance_eval do
        def name; "josh"; end
        def hair_color; "black"; end
      end

      multi = Spy.on_object(obj)
      obj.name

      uncalled = multi.uncalled.select { |spy| spy.original.owner == obj.singleton_class }
      assert_equal 1, uncalled.size
      assert_equal :hair_color, uncalled[0].name
    end

    it 'can be used to find unused instance methods' do
      klass = Class.new(Object)
      klass.class_eval do
        def name; "josh"; end
        def hair_color; "black"; end
      end

      multi = Spy.on_class(klass)
      obj = klass.new
      obj.name

      uncalled = multi.uncalled.select { |spy| spy.original.owner == klass }
      assert_equal 1, uncalled.size
      assert_equal :hair_color, uncalled[0].name
    end
  end
end
