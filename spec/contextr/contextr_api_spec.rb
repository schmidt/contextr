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
  it 'should allow the definition of pre method wrappers ' +
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
  it 'should allow the definition of post method wrappers ' +
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
  it 'should allow the definition of around method wrappers ' +
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

