require 'minitest/spec'
require 'minitest/autorun'

class Coffee
  def cost
    1
  end
end

module Milk
  def cost
    super + 1
  end
end

module Sugar
  def cost
    super + 2
  end
end

class SandboxTest < MiniTest::Spec
  describe "module inheritance" do
    # Include causes each module to be inserted after the base class in the inheritance chain
    # describe 'Class.include' do
    #   it 'should only call the original method' do
    #     Coffee.include Milk
    #     Coffee.include Sugar
    #     coffee = Coffee.new
    #     puts "Class.include: #{coffee.class.ancestors.join(', ')}"
    #     coffee.cost.must_equal 4 # fails
    #   end
    # end

    # Extend causes each module's methods to be mixed in to (and overwrite) the current class
    # describe 'Class.extend' do
    #   it 'should call every method that is overriden if I chain supers' do
    #     Coffee.extend Milk
    #     Coffee.extend Sugar
    #     coffee = Coffee.new
    #     puts "Class.extend: #{coffee.class.ancestors.join(', ')}"
    #     coffee.cost.must_equal 4 # fails
    #   end
    # end

    # Prepend causes each module to be inserted ahead of the base class in the inheritance chain
    # => We'll use this to implement a decorator-style pattern
    describe 'Class.prepend' do
      it 'should call every method that is overriden if I chain supers' do
        Coffee.prepend Milk
        Coffee.prepend Sugar
        coffee = Coffee.new
        puts "Class.prepend: #{coffee.class.ancestors.join(', ')}" 
        coffee.cost.must_equal 4 # passes
        # ensure uniqueness
        Coffee.prepend Milk
        coffee.cost.must_equal 4 # passes
        # ensure we can remove
        #TODO
        Coffee.remove_module Milk
        coffee.cost.must_equal 4
      end
    end

    # Extend causes each module's methods to be added to the inheritance chain (can still call super)
    # describe 'Instance.extend' do
    #   it 'should call every method that is overriden if I chain supers' do
    #     coffee = Coffee.new
    #     coffee.extend Milk
    #     coffee.extend Sugar
    #     puts "Instance.extend: #{coffee.class.ancestors.join(', ')}"
    #     coffee.cost.must_equal 4 # passes
    #   end
    # end
  end
end
