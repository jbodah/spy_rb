require 'test_helper'

class CollectionTest < Minitest::Spec
  before do
    @collection = Spy::Collection.new
  end

  describe '#insert' do
    it 'raises an error if the entry already exists' do
      obj = Object.new
      assert_raises Spy::Errors::AlreadySpiedError do
        @collection.insert(obj, obj.method(:to_s), Object.new)
        @collection.insert(obj, obj.method(:to_s), Object.new)
      end
    end
  end

  describe '#remove' do
    it "raises an error if the entry doesn't exist" do
      obj = Object.new
      assert_raises Spy::Errors::MethodNotSpiedError do
        @collection.remove(obj, obj.method(:to_s))
      end
    end

    it 'removes the entry' do
      obj = Object.new
      @collection.insert(obj, obj.method(:to_s), Object.new)
      assert @collection.include?(obj, obj.method(:to_s))
      @collection.remove(obj, obj.method(:to_s))
      refute @collection.include?(obj, obj.method(:to_s))
      @collection.insert(obj, obj.method(:to_s), Object.new)
      assert @collection.include?(obj, obj.method(:to_s))
    end
  end

  describe '#include?' do
    it "returns false if the entry isn't in the collection" do
      obj = Object.new
      refute @collection.include?(obj, obj.method(:to_s))
    end

    it 'returns true if the entry is in the collection' do
      obj = Object.new
      @collection.insert(obj, obj.method(:to_s), Object.new)
      assert @collection.include?(obj, obj.method(:to_s))
    end
  end

  describe '#remove_all' do
    it 'removes entry in the collection and yields the value' do
      arr = []
      obj = Object.new
      @collection.insert(obj, obj.method(:to_s), 1)
      obj = Object.new
      @collection.insert(obj, obj.method(:to_s), 2)
      @collection.remove_all {|v| arr << v }
      assert_equal [1, 2], arr
    end
  end
end
