require 'test_helper'

class NameTest < Minitest::Spec
  describe 'Spy::Instance' do
    it 'delegates name to original' do
      obj = Object.new
      spy = Spy.on(obj, :to_s)
      assert_equal :to_s, spy.name
    end
  end
end
