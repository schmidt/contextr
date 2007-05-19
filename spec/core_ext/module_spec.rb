require File.dirname(__FILE__) + '/../spec_helper'

describe 'Each first level module' do
  it 'should have the same name and namespace_free_name' do
    Math.namespace_free_name.should == Math.name
    Kernel.namespace_free_name.should == Kernel.name
  end

  it 'should have a namespace_free_name matching their constant' do
    Kernel.namespace_free_name.should == Kernel.to_s
    Kernel.namespace_free_name.should == "Kernel"
  end
end

describe 'Each sublevel module' do
  before do
    module ModuleTestA
      module B
        module C
        end
      end
    end
  end

  it 'should have a namespace free namespace_free_name' do
    ModuleTestA::B.namespace_free_name.should == "B"
    ModuleTestA::B::C.namespace_free_name.should == "C"
  end
end

describe "Each module" do
  it "should have a attr_accessor_with_default_setter" do
    lambda do
      class ClassSpecA
        attr_accessor_with_default_setter :miau do
          {}
        end
      end
    end.should_not raise_error
  end
end

describe "Each instance" do
  before do
    @instance = ClassSpecA.new
    @instance2 = ClassSpecA.new
  end
  
  it "should provide a getter method" do
    @instance.should respond_to( :miau )
  end
  
  it "should provide a setter method" do
    @instance.should respond_to( :miau= )
  end

end

describe "A getter method" do
  before do
    @getter = ClassSpecA.instance_method( :miau )
    @instance = ClassSpecA.new
    @instance2 = ClassSpecA.new
  end

  it "should not expect a parameter" do
    @getter.arity.should == 0
  end

  it "should provide the default value" do
    @instance.miau.should == Hash.new 
  end

  it "should provide the default value also multiple times" do
    @instance.miau.object_id.should == @instance.miau.object_id
  end

  it "should provide the different default values for different " +
     "instances" do
    @instance2.miau.object_id.should_not == @instance.miau.object_id
  end
end

describe "A setter method" do
  before do
    @setter = ClassSpecA.instance_method( :miau= )
    @instance = ClassSpecA.new
    @instance2 = ClassSpecA.new
  end

  it "should not expect a parameter" do
    @setter.arity.should == 1
  end

  it "should allow the setting of the corresonding instance variable" do
    begin
      @instance.miau = "blue"
    end.should == "blue"
    @instance.instance_variable_get( :@miau ).should == "blue"
  end
end
