require File.dirname(__FILE__) + "/../spec_helper.rb"

class ContextRClassSide
  class << self
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
end

describe "A contextified class" do
  it "should run a simple method " + 
          "*normally* when all layers are deactivated" do
    ContextRClassSide.non_contextified_method.should == 
        "non_contextified_method"
  end

  it "should run a simple method " +
          "*normally* when any layer is activated" do
    ContextR.with_layers( :simple_wrappers ) do
      ContextRClassSide.non_contextified_method.should == 
          "non_contextified_method"
    end
  end

  %w{pre post around}.each do | qualifier |
    it "should run a #{qualifier}-ed method " +
            "*normally* when all layers are deactivated" do
      ContextRClassSide.send( "#{qualifier}_wrapped_method" ).should == 
            "#{qualifier}_wrapped_method"
      ContextRClassSide.instance_variables.should_not include( 
            "@#{qualifier}_wrapped_method_called" )
    end

    it "should run a #{qualifier}-ed method " +
            "*normally* when any layer is activated" do
      ContextR.with_layers( :dummy ) do
        ContextRClassSide.send( "#{qualifier}_wrapped_method" ).should == 
              "#{qualifier}_wrapped_method"
        ContextRClassSide.instance_variables.should_not include( 
              "@#{qualifier}_wrapped_method_called" )
      end
    end

    it "should run a #{qualifier}-ed method with " +
            "additional behaviour when a specific layer is activated" do
      ContextR.with_layers( :simple_wrappers ) do
        ContextRClassSide.send( "#{qualifier}_wrapped_method" ).should == 
              "#{qualifier}_wrapped_method"
        ContextRClassSide.instance_variables.should include( 
              "@#{qualifier}_wrapped_method_called" )
      end
    end
  end
end
