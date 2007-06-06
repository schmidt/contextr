require File.dirname(__FILE__) + '/../spec_helper'

class ContextRApiFoo
  def non_contextified_method
    "non_contextified_method"
  end
  def foo
    "foo"
  end
end

describe 'Each class' do
  it 'should provide a method to enable a single layer' do
    lambda do
      class ContextRApiFoo 
        layer :bar
      end
    end.should_not raise_error
  end

  it 'should provide a method to access these layers by name' do
    begin
      class ContextRApiFoo
        bar
      end
    end.layer.should == ContextR::BarLayer
  end
end

describe 'Each layer in a class' do
  it 'should allow the definition of before method wrappers ' +
          'with `before`' do
    lambda do
      class ContextRApiFoo
        bar.before :foo do
          @before_visited = true
          @before_count = ( @before_count || 0 ) + 1
        end
      end
    end.should_not raise_error
  end
  it 'should allow the definition of after method wrappers ' +
          'with `after`' do
    lambda do
      class ContextRApiFoo
        bar.after :foo do
          @after_visited = true
          @after_count = ( @after_count || 0 ) + 1
        end
      end
    end.should_not raise_error
  end
  it 'should allow the definition of around method wrappers ' +
          'with `around`' do
    lambda do
      class ContextRApiFoo
        bar.around :foo do | method_nature |
          @around_visited = true
          @around_count = ( @around_count || 0 ) + 1
          method_nature.call_next
        end
      end
    end.should_not raise_error
  end
end

describe ContextR do
  it "should activate layers with activate_layers" do
    ContextR::activate_layers :foo
    ContextR::current_layers.should include(:foo)
  end

  it "should activate multiple layers wiht activate_layers" do
    ContextR::activate_layers :bar, :baz
    ContextR::current_layers.should include(:foo)
    ContextR::current_layers.should include(:bar)
    ContextR::current_layers.should include(:baz)
  end

  it "should deactivate layers with activate_layers" do
    ContextR::deactivate_layers :bar
    ContextR::current_layers.should_not include(:bar)
    ContextR::current_layers.should include(:foo)
    ContextR::current_layers.should include(:baz)
  end

  it "should deactivate multiple layers wiht activate_layers" do
    ContextR::deactivate_layers :foo, :baz
    ContextR::current_layers.should_not include(:bar)
    ContextR::current_layers.should_not include(:foo)
    ContextR::current_layers.should_not include(:baz)
  end

  it "should allow the registration of context sensors" do
    lambda do
      ContextR::add_context_sensor do
        [:foo]
      end
    end.should_not raise_error
  end

  it "should allow trigger all sensors an fetch the results in " +
     "sensored_context" do
    ContextR::add_context_sensor do
      [:bar]
    end
    ContextR::sensored_context.should include(:foo)
    ContextR::sensored_context.should include(:bar)
  end

  it "should allow the use of with_current_context and use the sensors to " +
     "compute it" do
    lambda do
      ContextR::with_current_context do
        ContextR::current_layers.should include(:foo)
        ContextR::current_layers.should include(:bar)
      end
    end.should_not raise_error
  end

  it "should allow the definition of context dependent behaviour using #in" do
    lambda do
      class ContextRApiFoo
        def in_method
          ret = "a"
          ContextR::in :foo do
            ret << "b"
          end
          ret << "c"
        end
      end
    end.should_not raise_error
  end

  it "should ignore behaviour defined in #in blocks when the specified " +
     "is not active" do
    ContextR::without_layer :foo do
      ContextRApiFoo.new.in_method.should == "ac"
    end
  end

  it "should execute behaviour defined in #in blocks when the specified " +
     "is active" do
    ContextR::with_layer :foo do
      ContextRApiFoo.new.in_method.should == "abc"
    end
  end
end
