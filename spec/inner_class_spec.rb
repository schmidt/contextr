require File.dirname(__FILE__) + '/spec_helper.rb'

class OuterClass
  def test_implicit_outer
  end
  def test_implicit_inner
  end
  def test_inner_over_outer
  end
  def test_outer_call
  end

  def inner_over_outer
    "outer"
  end

  def implicit_outer_method 
    "implicit_outer_method"
  end

  def outer_call 
    "outer"
  end

  module InnerClass
    in_layer :inner

    def test_implicit_outer
      implicit_outer_method
    end

    def test_implicit_inner
      implicit_inner_method
    end

    def test_inner_over_outer
      inner_over_outer
    end

    def test_outer_call
      outer.outer_call
    end

    def implicit_inner_method
      "implicit_inner_method"
    end

    def inner_over_outer
      "inner"
    end
  end

end

describe "Inner Class Semantics:" do
  it "Outer methods should be available implicitly" do
    ContextR::with_layer :inner do
      OuterClass.new.test_implicit_outer.should == "implicit_outer_method"
    end
  end

  it "Inner methods should be available implicitly as well" do
    ContextR::with_layer :inner do
      OuterClass.new.test_implicit_inner.should == "implicit_inner_method"
    end
  end

  it "Inner methods should have higher preference than outer ones" do
    ContextR::with_layer :inner do
      OuterClass.new.test_inner_over_outer.should == "inner"
    end
  end

  it "Outer methods should be available via outer from within inner methods" do
    ContextR::with_layer :inner do
      OuterClass.new.test_outer_call.should == "outer"
    end
  end
end
