require File.dirname(__FILE__) + '/../spec_helper'

class ProcSpecFoo
  def non_contextified_method
    "non_contextified_method"
  end
  def foo
    "foo"
  end
end

describe "A Proc" do
  before do
    @a = lambda do @a = true; "a" end
    @b = lambda do @b = true; "b" end
    @foo = ProcSpecFoo.new
  end

  it "should convert itself to an unbound method" do 
    @b.to_unbound_method( ProcSpecFoo ).should be_a_kind_of( UnboundMethod )
  end

  it "which should be bindable to an instance of the specified class" do 
    lambda do
      @b.to_unbound_method( ProcSpecFoo ).bind( @foo )
    end.should_not raise_error
  end

  it "which should execute the proc in turn" do
    @b.to_unbound_method( ProcSpecFoo ).bind( @foo ).call.should == "b"
    @foo.instance_variable_get( :@b ).should == true
  end

  it "should respond to `+`" do
    @b.should respond_to( :+ )
  end

  it "should build a joined block with `self.+( other_proc)`" do
    (@a + @b).should be_a_kind_of( Proc )
  end
end

describe "The result of `+` of two Procs" do
  before do
    @a = lambda do | arg | 
      arg || "a" 
    end
    @b = lambda do | arg | 
      arg || "b" 
    end
  end

  it "should give the correct return value" do
    (@a + @b).call( nil ).should == "b"
    (@b + @a).call( nil ).should == "a"
  end

  it "should pass through given parameters" do
    (@a + @b).call( 1 ).should == 1
  end
end
