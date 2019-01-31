require 'test_helper.rb'

class CalledTest < Minitest::Spec
  describe 'Spy::Instance#called?' do
    it 'works' do
      obj = Object.new
      spy = Spy.on(obj, :to_s)
      refute(spy.called?)
      obj.to_s
      assert(spy.called?)
    end
  end
end
