require File.dirname(__FILE__) + '/../spec_helper'

class MethodRestrictionTestSuperclass
end

describe "A LayerInClass" do 
  it "should allow the restriction of methods to certain layers" do
    lambda do
      class MethodRestrictionTest < MethodRestrictionTestSuperclass 
        layer :secret
        def foo
          "foo"
        end
        secret.use :foo
      end
    end.should_not raise_error
  end
end

describe "A restricted method" do
  before do
    @instance = MethodRestrictionTest.new
  end


  it "should be accessible when the corresponding layer is active" do
    lambda do
      ContextR::with_layer :secret do
        ContextR::SecretLayer.should be_active
        @instance.foo.should == "foo"
      end
    end.should_not raise_error
  end

  it "should _not_ be accessible when the corresponding layer is _in_active" do
    lambda do
      @instance.foo
    end.should raise_error( NoMethodError )
  end

  it "should call superclass methods when the corresponding layer is " +
     "_in_active" do
    class MethodRestrictionTestSuperclass
      def foo
        "bar"
      end
    end
    @instance.foo.should == "bar"
  end

end
