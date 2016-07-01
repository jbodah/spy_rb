require 'test_helper'

class RegistryTest < Minitest::Spec
  before do
    @registry = Spy::Registry.new
  end

  describe '#insert' do
    it 'raises an error if the entry already exists' do
      obj = Object.new
      assert_raises Spy::Errors::AlreadySpiedError do
        @registry.insert(obj, obj.method(:to_s), Object.new)
        @registry.insert(obj, obj.method(:to_s), Object.new)
      end
    end
  end

  describe '#remove' do
    it "raises an error if the entry doesn't exist" do
      obj = Object.new
      assert_raises Spy::Errors::MethodNotSpiedError do
        @registry.remove(obj, obj.method(:to_s))
      end
    end

    it 'removes the entry' do
      obj = Object.new
      @registry.insert(obj, obj.method(:to_s), Object.new)
      assert @registry.include?(obj, obj.method(:to_s))
      @registry.remove(obj, obj.method(:to_s))
      refute @registry.include?(obj, obj.method(:to_s))
      @registry.insert(obj, obj.method(:to_s), Object.new)
      assert @registry.include?(obj, obj.method(:to_s))
    end
  end

  describe '#include?' do
    it "returns false if the entry isn't in the registry" do
      obj = Object.new
      refute @registry.include?(obj, obj.method(:to_s))
    end

    it 'returns true if the entry is in the registry' do
      obj = Object.new
      @registry.insert(obj, obj.method(:to_s), Object.new)
      assert @registry.include?(obj, obj.method(:to_s))
    end
  end

  describe '#remove_all' do
    it 'removes entry in the registry and yields the value' do
      arr = []
      obj = Object.new
      @registry.insert(obj, obj.method(:to_s), 1)
      obj = Object.new
      @registry.insert(obj, obj.method(:to_s), 2)
      @registry.remove_all {|v| arr << v }
      assert_equal [1, 2], arr
    end
  end
end
