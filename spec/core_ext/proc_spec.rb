require File.dirname(__FILE__) + '/../spec_helper'

class ProcSpecFoo
  def non_contextified_method
    "non_contextified_method"
  end
  def foo
    "foo"
  end
end

context "A Proc" do
  setup do
    @a = lambda do @a = true; "a" end
    @b = lambda do @b = true; "b" end
    @foo = ProcSpecFoo.new
  end

  specify "should convert itself to an unbound method" do 
    @b.to_unbound_method( ProcSpecFoo ).should_be_kind_of UnboundMethod
  end

  specify "which should be bindable to an instance of the specified class" do 
    lambda do
      @b.to_unbound_method( ProcSpecFoo ).bind( @foo )
    end.should_not raise_error
  end

  specify "which should execute the proc in turn" do
    @b.to_unbound_method( ProcSpecFoo ).bind( @foo ).call.should == "b"
    @foo.instance_variable_get( :@b ).should == true
  end

  specify "should respond to `+`" do
    @b.should_respond_to :+
  end

  specify "should build a joined block with `self.+( other_proc)`" do
    (@a + @b).should_be_kind_of Proc
  end
end

context "The result of `+` of two Procs" do
  setup do
    @a = lambda do | arg | 
      arg || "a" 
    end
    @b = lambda do | arg | 
      arg || "b" 
    end
  end

  specify "should give the correct return value" do
    (@a + @b).call( nil ).should == "b"
    (@b + @a).call( nil ).should == "a"
  end

  specify "should pass through given parameters" do
    (@a + @b).call( 1 ).should == 1
  end
end
