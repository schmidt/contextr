require File.dirname(__FILE__) + '/../spec_helper'

class ContextRApiFoo
  def non_contextified_method
    "non_contextified_method"
  end
  def foo
    "foo"
  end
end

context 'Each class' do
  specify 'should provide a method to enable a single layer' do
    lambda do
      class ContextRApiFoo 
        layer :bar
      end
    end.should_not raise_error
  end

  specify 'should provide a method to access these layers by name' do
    begin
      class ContextRApiFoo
        bar
      end
    end.layer.should == ContextR::BarLayer
  end
end

context 'Each layer in a class' do
  specify 'should allow the definition of pre method wrappers ' +
          'with `pre`' do
    lambda do
      class ContextRApiFoo
        bar.pre :foo do
          @pre_visited = true
          @pre_count = ( @pre_count || 0 ) + 1
        end
      end
    end.should_not raise_error
  end
  specify 'should allow the definition of post method wrappers ' +
          'with `post`' do
    lambda do
      class ContextRApiFoo
        bar.post :foo do
          @post_visited = true
          @post_count = ( @post_count || 0 ) + 1
        end
      end
    end.should_not raise_error
  end
  specify 'should allow the definition of around method wrappers ' +
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
  specify 'should allow the definition of around method wrappers ' +
          'with `wrap`' do
    lambda do
      class ContextRApiFoo
        bar.wrap :foo do | method_nature |
          @around_visited = true
          @around_count = ( @around_count || 0 ) + 1
          method_nature.call_next
        end
      end
    end.should_not raise_error
  end
end

context "An instance of a contextified class" do
  setup do
    @instance = ContextRApiFoo.new
  end

  specify "should run a simple method " + 
          "*normally* when all layers are deactivated" do
    @instance.non_contextified_method.should == "non_contextified_method"
  end

  specify "should run a simple method " +
          "*normally* when any layer is activated" do
    ContextR.with_layers( :bar ) do
      @instance.non_contextified_method.should == "non_contextified_method"
    end
  end

  specify "should run a contextified method " +
          "*normally* when all layers are deactivated" do
    @instance.foo.should == "foo"
  end

  specify "should run a contextified method " +
          "*normally* when any layer is activated" do
    ContextR.with_layers( :baz ) do
      @instance.foo.should == "foo"
    end
  end

  specify "should run a contextified method with " +
          "additional behaviour when a specific layer is activated" do
    ContextR.with_layers( :bar ) do
      @instance.foo.should == "foo"
    end
    @instance.instance_variable_get( :@pre_visited ).should == true
    @instance.instance_variable_get( :@post_visited ).should == true
    @instance.instance_variable_get( :@around_visited ).should == true
  end
end
