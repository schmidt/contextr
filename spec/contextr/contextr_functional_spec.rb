require File.dirname(__FILE__) + '/../spec_helper'

class SimpleWrapperClass
  def non_contextified_method
    "non_contextified_method"
  end
  def before_wrapped_method
    "before_wrapped_method"
  end
  def after_wrapped_method
    "after_wrapped_method"
  end
  def around_wrapped_method
    "around_wrapped_method"
  end

  layer :simple_wrappers, :dummy

  simple_wrappers.before :before_wrapped_method do
    @before_wrapped_method_called = true
  end
  simple_wrappers.after :after_wrapped_method do
    @after_wrapped_method_called = true
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

  %w{before after around}.each do | qualifier |
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

  def beforeed_method
    @execution << "core"
    "beforeed_method"
  end

  def aftered_method
    @execution << "core"
    "aftered_method"
  end

  def arounded_method
    @execution << "core"
    "arounded_method"
  end

  layer :outer_layer, :inner_layer

  inner_layer.before :beforeed_method do
    @execution << "inner_layer"
  end

  outer_layer.before :beforeed_method do
    @execution << "outer_layer"
  end

  inner_layer.after :aftered_method do
    @execution << "inner_layer"
  end

  outer_layer.after :aftered_method do
    @execution << "outer_layer"
  end

  inner_layer.around :arounded_method do | n |
    @execution << "inner_layer_before"
    n.call_next
    @execution << "inner_layer_after"
  end

  outer_layer.around :arounded_method do | n |
    @execution << "outer_layer_before"
    n.call_next
    @execution << "outer_layer_after"
  end

  def contextualized_method
    @execution << "core"
    "contextualized_method"
  end

  layer :break_in_before, :break_in_after, :break_in_around
  layer :other_layer

  break_in_before.before :contextualized_method do | n |
    n.return_value = "contextualized_method"
    @execution << "breaking_before"
    n.break!
  end
  break_in_after.after :contextualized_method do | n |
    @execution << "breaking_after"
    n.break!
  end
  break_in_around.around :contextualized_method do | n |
    @execution << "breaking_around"
    n.return_value = "contextualized_method"
    n.break!
    n.call_next
  end

  other_layer.before :contextualized_method do | n |
    @execution << "other_before"
  end
  other_layer.after :contextualized_method do | n |
    @execution << "other_after"
  end
  other_layer.around :contextualized_method do | n |
    @execution << "other_around"
    n.call_next
  end

  layer :multiple_befores, :multiple_afters, :multiple_arounds
  multiple_befores.before :contextualized_method do
    @execution << "first_before"
  end
  multiple_befores.before :contextualized_method do
    @execution << "second_before"
  end

  multiple_afters.after :contextualized_method do
    @execution << "first_after"
  end
  multiple_afters.after :contextualized_method do
    @execution << "second_after"
  end

  multiple_arounds.around :contextualized_method do | n |
    @execution << "first_around_before"
    n.call_next
    @execution << "first_around_after"
  end
  multiple_arounds.around :contextualized_method do | n |
    @execution << "second_around_before"
    n.call_next
    @execution << "second_around_after"
  end
end

before_spec = lambda do | instance |
  instance.execution.shift.should == "outer_layer"
  instance.execution.shift.should == "inner_layer"
  instance.execution.shift.should == "core"
end
after_spec = lambda do | instance |
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "inner_layer"
  instance.execution.shift.should == "outer_layer"
end
around_spec = lambda do | instance |
  instance.execution.shift.should == "outer_layer_before"
  instance.execution.shift.should == "inner_layer_before"
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "inner_layer_after"
  instance.execution.shift.should == "outer_layer_after"
end

before_break_spec = lambda do | instance |
  instance.execution.shift.should == "breaking_before"
end
after_break_spec = lambda do | instance |
  instance.execution.shift.should == "other_before"
  instance.execution.shift.should == "other_around"
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "other_after"
  instance.execution.shift.should == "breaking_after"
end
around_break_spec = lambda do | instance |
  instance.execution.shift.should == "other_before"
  instance.execution.shift.should == "breaking_around"
end

before_multiple_spec = lambda do | instance |
  instance.execution.shift.should == "first_before"
  instance.execution.shift.should == "second_before"
  instance.execution.shift.should == "core"
end
after_multiple_spec = lambda do | instance |
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "second_after"
  instance.execution.shift.should == "first_after"
end
around_multiple_spec = lambda do | instance |
  instance.execution.shift.should == "first_around_before"
  instance.execution.shift.should == "second_around_before"
  instance.execution.shift.should == "core"
  instance.execution.shift.should == "second_around_after"
  instance.execution.shift.should == "first_around_after"
end

%w{before after around}.each do | qualifier |
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
