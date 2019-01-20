require_relative 'test_helper'

class CalledTest < Minitest::Spec
  describe 'Spy::Instance#called?' do
    it 'works' do
      obj = Object.new
      spy = Spy.on(obj, :to_s)
      assert_equal spy.called?, false
      obj.to_s
      assert_equal spy.called?, true
    end
  end
end