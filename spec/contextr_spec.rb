require File.dirname(__FILE__) + '/spec_helper.rb'

module AddressMethods
  def to_s
    "#{super} (#{yield(:receiver).address})"
  end
end

class University < Struct.new(:name, :address)
  def to_s
    name
  end

  in_layer :address do
    include AddressMethods
  end
end

class Student < Struct.new(:name, :address, :education)
  def to_s
    name
  end

  in_layer :address do
    include AddressMethods
  end
  in_layer :education do
    def to_s
      "#{super}, #{yield(:receiver).education}"
    end
  end
end

class Ordering 
  def inner_outer
    "base"
  end

  module InnerMethods
    def inner_outer 
      "inner #{super} inner"
    end
  end
  module OuterMethods
    def inner_outer
      "outer #{super} outer"
    end
  end
  in_layer :multiple_modules do
    include InnerMethods
    include OuterMethods
  end
end

class ExceptionExample
  def secure
    insecure
  rescue RuntimeError
    "caught in secure method"
  end

  def insecure
    raise "insecure action failed"
  end

  in_layer :security do
    def insecure
      super
    rescue RuntimeError
      "caught in security layer"
    end
  end
end

describe "A contextified object" do
  before do
    institute = University.new("HPI", "Potsdam") 
    @student = Student.new("Gregor Schmidt", "Berlin", institute)
  end

  it "should show base behaviour without activated layers" do
    @student.to_s.should == "Gregor Schmidt"
  end
  
  it "should show specific behaviour with a single activated layer" do
    ContextR::with_layer :address do
      @student.to_s.should == "Gregor Schmidt (Berlin)"
    end
  end

  it "should show base behaviour after deactivating all layers" do
    ContextR::with_layer :address do
      @student.to_s.should == "Gregor Schmidt (Berlin)"
    end
    @student.to_s.should == "Gregor Schmidt"
  end

  it "should show specific behaviour down the whole stack for all layers" do
    ContextR::with_layers :address, :education do
      @student.to_s.should == "Gregor Schmidt (Berlin), HPI (Potsdam)"
    end
  end

  it "should take care of layer activation odering" do
    ContextR::with_layers :address do
      ContextR::with_layers :education do
        @student.to_s.should == "Gregor Schmidt (Berlin), HPI (Potsdam)"
      end
    end
    ContextR::with_layers :education do
      ContextR::with_layers :address do
        @student.to_s.should == "Gregor Schmidt, HPI (Potsdam) (Berlin)"
      end
    end
  end

  it "should avoid double activation, but update ordering" do
    ContextR::with_layers :education, :address do
      ContextR::active_layers.should == [:address, :education]
      ContextR::with_layer :education do
        ContextR::active_layers.should == [:education, :address]
      end
    end
  end

  it "should also activate multiple modules per layer" do
    ContextR::with_layers :multiple_modules do
      Ordering.new.inner_outer.should == "outer inner base inner outer"
    end
  end

  it "should show new specific behaviour after changing module definitions" do
    class Student
      in_layer :education do
        def to_s
          "#{super} @ #{yield(:receiver).education}"
        end
      end
    end
    ContextR::with_layer :education do
      @student.to_s.should == "Gregor Schmidt @ HPI"
    end
    class Student
      in_layer :education do
        def to_s
          "#{super}, #{yield(:receiver).education}"
        end
      end
    end
  end

  it "should still work after changing contextified instance methods" do
    class Student
      def to_s
        "Student: #{name}"
      end
    end
    ContextR::with_layer :education do
      @student.to_s.should == "Student: Gregor Schmidt, HPI"
    end
    class Student
      def to_s
        name
      end
    end
  end
end

describe "A method modules defining context dependent behaviour" do
  before do
    institute = University.new("HPI", "Potsdam") 
    @student = Student.new("Gregor Schmidt", "Berlin", institute)
  end

  it "should have inner state" do
    class Student
      in_layer :log do
        def to_s
          @i ||= 0
          @i += 1
          "#{@i}: #{super}"
        end
      end
    end
    ContextR::with_layer :log do
      @student.to_s.should == "1: Gregor Schmidt"
      @student.to_s.should == "2: Gregor Schmidt"
    end
  end

  it "should not lose its state after layer deactivation" do
    ContextR::with_layer :log do
      @student.to_s.should == "3: Gregor Schmidt"
    end
  end
  
  it "should not lose its state after redefinition of the module" do
    class Student
      in_layer :log do
        def to_s
          @i ||= 0
          @i += 1
          "(#{@i}) #{super}"
        end
      end
    end
    ContextR::with_layer :log do
      @student.to_s.should == "(4) Gregor Schmidt"
    end
  end

  it "should not lose its state after redefinition of base method" do
    class Student
      def to_s
        name + " x"
      end
    end
    ContextR::with_layer :log do
      @student.to_s.should == "(5) Gregor Schmidt x"
    end
    class Student
      def to_s
        name
      end
    end
  end
end

describe "ContextR" do
  it "should provide a method to query for all active layers" do
    ContextR::with_layer :log do
      ContextR::active_layers.should == [:log]
    end
  end

  it "should provide a method to query for all layers ever defined" do
    [:address, :education, :log, :multiple_modules].each do |layer|
      ContextR::layers.sort_by{ |s| s.to_s }.should include(layer)
    end
  end
end

describe "ContextR" do
  it "should propagate exceptions into outer layers first" do

    instance = ExceptionExample.new

    instance.secure.should == "caught in secure method"

    ContextR::with_layer :security do
      instance.secure.should == "caught in security layer"
    end
  end
end
