require 'test_helper'

class TestSuperclass
  def self.superclass_singleton_owned_method; end
  def superclass_owned_method; end
end

module TestModule
  def module_owned_method; end
end

class TestClass < TestSuperclass
  include TestModule

  def self.existing_singleton_owned_method; end
  def class_owned_method; end
end

class SpyTest < Minitest::Spec
  def eval_option(opt, *args)
    opt.respond_to?(:call) ? opt.call(*args) : opt
  end

  # Wrapping
  [
    {
      name:     'an instance and a dynamic singleton-owned method',
      to_spy:   proc { TestClass.new },
      msg:      :singleton_owned_method,
      original: proc { |spied, sym| spied.define_singleton_method(sym, proc {}); spied.method(sym) },
      cleanup:  proc { |spied, sym| spied.singleton_class.class_eval { remove_method sym } },
      owner:    proc { |spied| spied.singleton_class }
    },
    {
      name:     'a class and a dynamic singleton-owned method',
      to_spy:   TestClass,
      msg:      :singleton_owned_method,
      original: proc { |spied, sym| spied.define_singleton_method(sym, proc {}); spied.method(sym) },
      cleanup:  proc { |spied, sym| spied.singleton_class.class_eval { remove_method sym } },
      owner:    TestClass.singleton_class
    },
    {
      name:     'a module and a dynamic singleton-owned method',
      to_spy:   TestModule,
      msg:      :singleton_owned_method,
      original: proc { |spied, sym| spied.define_singleton_method(sym, proc {}); spied.method(sym) },
      cleanup:  proc { |spied, sym| spied.singleton_class.class_eval { remove_method sym } },
      owner:    TestModule.singleton_class
    },
    {
      name:     'a class and an existing singleton-owned method',
      to_spy:   TestClass,
      msg:      :existing_singleton_owned_method,
      original: proc { TestClass.method :existing_singleton_owned_method },
      owner:    TestClass.singleton_class
    },
  ].each do |t|
    describe t[:name] do
      before do
        @spied = eval_option(t[:to_spy])
        @sym = t[:msg]
        @original_method = eval_option(t[:original], @spied, @sym)
        # sanity check
        assert_equal eval_option(t[:owner], @spied), @original_method.owner
      end

      after do
        Spy.restore :all
        eval_option(t[:cleanup], @spied, @sym)
      end

      describe 'Spy.on' do
        it 'chooses a wrapping strategy' do
          s = Spy.on(@spied, @sym)
          assert_equal s.strategy.class, Spy::Instance::Strategy::Wrap
        end

        it 'wraps the method' do
          Spy.on(@spied, @sym)
          wrapped = @spied.method(@sym)
          refute_equal @original_method, wrapped
          assert_equal @original_method.owner, wrapped.owner
          refute_equal @original_method.source_location, wrapped.source_location
        end
      end

      describe 'Spy.restore' do
        it 'restores the original method' do
          Spy.on(@spied, @sym)
          Spy.restore(@spied, @sym)
          restored = @spied.method(@sym)
          assert_equal @original_method, restored
        end
      end
    end
  end

  # Intercepting
  [
    { name: 'an instance and a class-owned method',             to_spy: proc { TestClass.new }, msg: :class_owned_method,               owner: TestClass },
    { name: 'an instance and a module-owned method',            to_spy: proc { TestClass.new }, msg: :module_owned_method,              owner: TestModule },
    { name: 'an instance and a superclass-owned method',        to_spy: proc { TestClass.new }, msg: :superclass_owned_method,          owner: TestSuperclass },
    # NOTE: Module#include only adds instance methods. You can make a PR if you're including modules in your singleton classes
    #{ name: 'a class and a module-singleton-owned method',  to_spy: Proc.new { TestClass },     msg: :module_singleton_owned_method,  owner: TestModule.singleton_class }
    { name: 'a class and a superclass-singleton-owned method',  to_spy: proc { TestClass },     msg: :superclass_singleton_owned_method, owner: TestSuperclass.singleton_class },
  ].each do |t|
    describe t[:name] do
      before do
        @spied = t[:to_spy].call
        @sym = t[:msg]
        @original_method = @spied.method(@sym)
        assert_equal t[:owner], @original_method.owner
      end

      after do
        Spy.restore :all
      end

      describe 'Spy.on' do
        it 'chooses an intercept strategy' do
          s = Spy.on(@spied, @sym)
          assert_equal s.strategy.class, Spy::Instance::Strategy::Intercept
        end

        it 'defines a singleton method' do
          Spy.on(@spied, @sym)
          singleton_method = @spied.method(@sym)
          refute_equal @original_method, singleton_method
          assert_equal @spied.singleton_class, singleton_method.owner
          refute_equal @original_method.source_location, singleton_method.source_location
        end
      end

      describe 'Spy.restore' do
        it 'restores the original method' do
          Spy.on(@spied, @sym)
          Spy.restore(@spied, @sym)
          restored = @spied.method(@sym)
          assert_equal @original_method, restored
        end
      end
    end
  end

  describe 'any_instance' do
    describe 'Spy.on_any_instance' do
      describe 'an instance' do
        it 'throws an ArgumentError' do
          obj = Object.new
          assert_raises ArgumentError do
            Spy.on_any_instance(obj, :hello)
          end
        end
      end

      # Wrapping
      [
        { name: 'a class and a class-owned method',   to_spy: proc { TestClass },   msg: :class_owned_method },
        { name: 'a module and a module-owned method', to_spy: proc { TestModule },  msg: :module_owned_method }
      ].each do |t|
        describe t[:name] do
          describe 'and a class-owned method' do
            before do
              @spied = t[:to_spy].call
              @sym = t[:msg]
              @original_method = @spied.instance_method(@sym)
            end

            after do
              Spy.restore :all
            end

            it 'chooses a wrapping strategy' do
              s = Spy.on_any_instance(@spied, @sym)
              assert_equal s.strategy.class, Spy::Instance::Strategy::Wrap
            end

            it 'wraps the method' do
              Spy.on_any_instance(@spied, @sym)
              wrapped = @spied.instance_method(@sym)
              refute_equal @original_method, wrapped
              assert_equal @original_method.owner, wrapped.owner
              refute_equal @original_method.source_location, wrapped.source_location
            end

            it 'restores the original method' do
              Spy.on_any_instance(@spied, @sym)
              Spy.restore(@spied, @sym, :instance_method)
              restored = @spied.instance_method(@sym)
              assert_equal @original_method, restored
            end
          end
        end
      end

      # Intercepting
      [
        { name: 'a class and a superclass-owned method',  msg: :superclass_owned_method },
        { name: 'a class and a module-owned method',      msg: :module_owned_method }
      ].each do |t|
        describe t[:name] do
          before do
            @spied = TestClass
            @sym = t[:msg]
            @original_method = @spied.instance_method(@sym)
          end

          after do
            Spy.restore :all
          end

          it 'chooses an intercept strategy' do
            s = Spy.on_any_instance(@spied, @sym)
            assert_equal s.strategy.class, Spy::Instance::Strategy::Intercept
          end

          it 'defines a method on the class' do
            Spy.on_any_instance(@spied, @sym)
            class_defined_method = @spied.instance_method(@sym)
            refute_equal @original_method, class_defined_method
            assert_equal @spied, class_defined_method.owner
            refute_equal @original_method.source_location, class_defined_method.source_location
          end

          it 'restores the original method' do
            Spy.on_any_instance(@spied, @sym)
            Spy.restore(@spied, @sym, :instance_method)
            restored = @spied.instance_method(@sym)
            assert_equal @original_method, restored
          end
        end
      end
    end
  end
end
