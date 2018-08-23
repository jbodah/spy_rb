require 'test_helper'

class UtilTest < Minitest::Spec
  describe 'type analysis' do
    it 'does things' do
      klass = Class.new(Object)
      klass.class_eval do
        def name
          "josh"
        end

        def compliment(color)
          case color
          when "red" then ["blue", "yellow"]
          when "black" then "white"
          else nil
          end
        end
      end

      multi = Spy.on_class(klass)
      multi = Spy::Util::TypeAnalysis.new(multi).decorate
      obj = klass.new

      obj.name
      obj.compliment("red")
      obj.compliment("black")
      obj.compliment("green")

      type_info = multi.type_info

      assert_equal [], type_info[:name][:args]
      assert_equal [String], type_info[:name][:return_value].to_a

      assert_equal [String], type_info[:compliment][:args][0].to_a
      assert_equal [[Array, String], String, NilClass], type_info[:compliment][:return_value].to_a
    end
  end
end
