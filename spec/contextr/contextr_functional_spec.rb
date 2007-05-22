require File.dirname(__FILE__) + '/../spec_helper'

class SimpleWrapperClass
  def non_contextified_method
    "non_contextified_method"
  end
  def pre_wrapped_method
    "pre_wrapped_method"
  end
  def post_wrapped_method
    "post_wrapped_method"
  end
  def around_wrapped_method
    "around_wrapped_method"
  end

  layer :simple_wrappers, :dummy

  simple_wrappers.pre :pre_wrapped_method do
    @pre_wrapped_method_called = true
  end
  simple_wrappers.post :post_wrapped_method do
    @post_wrapped_method_called = true
  end
  simple_wrappers.around :around_wrapped_method do | n |
    @around_wrapped_method_called = true
    n.call_next
  end
end
describe "An instance of a contextified class" do
  before do
    @instance = SimpleWrapperClass.new
  end

  it "should run a simple method " + 
          "*normally* when all layers are deactivated" do
    @instance.non_contextified_method.should == "non_contextified_method"
  end

  it "should run a simple method " +
          "*normally* when any layer is activated" do
    ContextR.with_layers( :simple_wrappers ) do
      @instance.non_contextified_method.should == "non_contextified_method"
    end
  end

  %w{pre post around}.each do | qualifier |
    it "should run a #{qualifier}-ed method " +
            "*normally* when all layers are deactivated" do
      @instance.send( "#{qualifier}_wrapped_method" ).should == 
            "#{qualifier}_wrapped_method"
      @instance.instance_variables.should_not include( 
            "@#{qualifier}_wrapped_method_called" )
    end

    it "should run a #{qualifier}-ed method " +
            "*normally* when any layer is activated" do
      ContextR.with_layers( :dummy ) do
        @instance.send( "#{qualifier}_wrapped_method" ).should == 
              "#{qualifier}_wrapped_method"
        @instance.instance_variables.should_not include( 
              "@#{qualifier}_wrapped_method_called" )
      end
    end

    it "should run a #{qualifier}-ed method with " +
            "additional behaviour when a specific layer is activated" do
      ContextR.with_layers( :simple_wrappers ) do
        @instance.send( "#{qualifier}_wrapped_method" ).should == 
              "#{qualifier}_wrapped_method"
        @instance.instance_variables.should include( 
              "@#{qualifier}_wrapped_method_called" )
      end
    end

    it "should run a #{qualifier}-ed method without additional " +
            "behaviour when a specific layer is activated and afterwards " + 
            "deactivated" do
      ContextR.with_layers( :simple_wrappers ) do
        ContextR.without_layers( :simple_wrappers ) do
          @instance.send( "#{qualifier}_wrapped_method" ).should == 
                "#{qualifier}_wrapped_method"
          @instance.instance_variables.should_not include( 
                "@#{qualifier}_wrapped_method_called" )
        end
      end
    end
  end
end

class NestedLayerActivationClass
  attr_accessor :execution
  def initialize
    @execution = []
  end

  def preed_method
    @execution << "core"
    "preed_method"
  end

  def posted_method
    @execution << "core"
    "posted_method"
  end

  def arounded_method
    @execution << "core"
    "arounded_method"
  end

  layer :outer_layer, :inner_layer

  inner_layer.pre :preed_method do
    @execution << "inner_layer"
  end

  outer_layer.pre :preed_method do
    @execution << "outer_layer"
  end

  inner_layer.post :posted_method do
    @execution << "inner_layer"
  end

  outer_layer.post :posted_method do
    @execution << "outer_layer"
  end

  inner_layer.around :arounded_method do | n |
    @execution << "inner_layer_pre"
    n.call_next
    @execution << "inner_layer_post"
  end

  outer_layer.around :arounded_method do | n |
    @execution << "outer_layer_pre"
    n.call_next
    @execution << "outer_layer_post"
  end

  def contextualized_method
    @execution << "core"
    "contextualized_method"
  end

  layer :break_in_pre, :break_in_post, :break_in_around
  layer :other_layer

  break_in_pre.pre :contextualized_method do | n |
    n.return_value = "contextualized_method"
    @execution << "breaking_pre"
    n.break!
  end
  break_in_post.post :contextualized_method do | n |
    @execution << "breaking_post"
    n.break!
  end
  break_in_around.around :contextualized_method do | n |
    @execution << "breaking_around"
    n.return_value = "contextualized_method"
    n.break!
    n.call_next
  end

  other_layer.pre :contextualized_method do | n |
    @execution << "other_pre"
  end
  other_layer.post :contextualized_method do | n |
    @execution << "other_post"
  end
  other_layer.around :contextualized_method do | n |
    @execution << "other_around"
    n.call_next
  end

  layer :multiple_pres, :multiple_posts, :multiple_arounds
  multiple_pres.pre :contextualized_method do
    @execution << "first_pre"
  end
  multiple_pres.pre :contextualized_method do
    @execution << "second_pre"
  end

  multiple_posts.post :contextualized_method do
    @execution << "first_post"
  end
  multiple_posts.post :contextualized_method do
    @execution << "second_post"
  end

  multiple_arounds.around :contextualized_method do | n |
    @execution << "first_around_pre"
    n.call_next
    @execution << "first_around_post"
  end
  multiple_arounds.around :contextualized_method do | n |
    @execution << "second_around_pre"
    n.call_next
    @execution << "second_around_post"
  end
end

pre_spec = lambda do | instance |
  instance.execution.shift.should == "outer_layer"
  instance.execution.shift.should == "inner_layer"
  instance.execution.shift.should == "core"
end
post_spec = lambda do | instance |
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "inner_layer"
  instance.execution.shift.should == "outer_layer"
end
around_spec = lambda do | instance |
  instance.execution.shift.should == "outer_layer_pre"
  instance.execution.shift.should == "inner_layer_pre"
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "inner_layer_post"
  instance.execution.shift.should == "outer_layer_post"
end

pre_break_spec = lambda do | instance |
  instance.execution.shift.should == "breaking_pre"
end
post_break_spec = lambda do | instance |
  instance.execution.shift.should == "other_pre"
  instance.execution.shift.should == "other_around"
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "other_post"
  instance.execution.shift.should == "breaking_post"
end
around_break_spec = lambda do | instance |
  instance.execution.shift.should == "other_pre"
  instance.execution.shift.should == "breaking_around"
end

pre_multiple_spec = lambda do | instance |
  instance.execution.shift.should == "first_pre"
  instance.execution.shift.should == "second_pre"
  instance.execution.shift.should == "core"
end
post_multiple_spec = lambda do | instance |
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "second_post"
  instance.execution.shift.should == "first_post"
end
around_multiple_spec = lambda do | instance |
  instance.execution.shift.should == "first_around_pre"
  instance.execution.shift.should == "second_around_pre"
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "second_around_post"
  instance.execution.shift.should == "first_around_post"
end

%w{pre post around}.each do | qualifier |
  describe "#{qualifier.capitalize} wrappers within a method" do
    before do
      @instance = NestedLayerActivationClass.new
    end
    it "should run in the sequence of nesting, when using nested " +
            "activation" do
      ContextR::with_layers :outer_layer do
        ContextR::with_layers :inner_layer do
          @instance.send( "#{qualifier}ed_method" ).should == 
                "#{qualifier}ed_method"
        end
      end
      eval("#{qualifier}_spec").call( @instance )
    end
    it "should run in the sequence of nesting, when using simultaneous " +
            "activation" do
      ContextR::with_layers :outer_layer, :inner_layer do
        @instance.send( "#{qualifier}ed_method" ).should == 
              "#{qualifier}ed_method"
      end
      eval("#{qualifier}_spec").call( @instance )
    end

    it "should run in the sequence of definition within the same layer" do
      ContextR::with_layers "multiple_#{qualifier}s".to_sym do
        @instance.contextualized_method.should == "contextualized_method"
      end
      eval("#{qualifier}_multiple_spec").call( @instance )
    end

    it "should be able to stop the execution with `break!`" do
      ContextR::with_layers "break_in_#{qualifier}".to_sym, :other_layer do
        @instance.contextualized_method.should == "contextualized_method"
      end
      eval("#{qualifier}_break_spec").call( @instance )
    end
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
end
