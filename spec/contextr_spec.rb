require File.dirname(__FILE__) + '/spec_helper.rb'

module AddressMethods
  def to_s
    "#{yield(:next)} (#{yield(:receiver).address})"
  end
end

class University < Struct.new(:name, :address)
  def to_s
    name
  end

  include AddressMethods => :address
end

class Student < Struct.new(:name, :address, :education)
  def to_s
    name
  end

  include AddressMethods => :address

  module EducationMethods
    def to_s
      "#{yield(:next)}, #{yield(:receiver).education}"
    end
  end

  include EducationMethods => :education
end

class Ordering 
  def test
    "base"
  end

  module InnerMethods
    def test
      "inner #{yield(:next)} inner"
    end
  end
  include InnerMethods => :multiple_modules

  module OuterMethods
    def test
      "outer #{yield(:next)} outer"
    end
  end
  include OuterMethods => :multiple_modules
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
    ContextR::with_layers :education, :address do
      @student.to_s.should == "Gregor Schmidt (Berlin), HPI (Potsdam)"
    end
  end

  it "should take care of layer activation odering" do
    ContextR::with_layers :education do
      ContextR::with_layers :address do
        @student.to_s.should == "Gregor Schmidt (Berlin), HPI (Potsdam)"
      end
    end
    ContextR::with_layers :address do
      ContextR::with_layers :education do
        @student.to_s.should == "Gregor Schmidt, HPI (Potsdam) (Berlin)"
      end
    end
  end

  it "should avoid double activation, but update ordering" do
    ContextR::with_layers :education, :address do
      ContextR::layer_symbols.should == [:education, :address]
      ContextR::with_layer :education do
        ContextR::layer_symbols.should == [:address, :education]
      end
    end
  end

  it "should also activate multiple modules per layer" do
    ContextR::with_layers :multiple_modules do
      Ordering.new.test.should == "outer inner base inner outer"
    end
  end

  it "should show new specific behaviour after changing module definitions" do
    module Student::EducationMethods
      def to_s
        "#{yield(:next)} @ #{yield(:receiver).education}"
      end
    end
    ContextR::with_layer :education do
      @student.to_s.should == "Gregor Schmidt @ HPI"
    end
    module Student::EducationMethods
      def to_s
        "#{yield(:next)}, #{yield(:receiver).education}"
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
      module LogMethods
        def to_s
          @i ||= 0
          @i += 1
          "#{@i}: #{yield(:next)}"
        end
      end
      include LogMethods => :log
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
      module LogMethods
        def to_s
          @i ||= 0
          @i += 1
          "(#{@i}) #{yield(:next)}"
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
