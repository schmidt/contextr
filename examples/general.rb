require File.dirname(__FILE__) + "/../lib/contextr.rb"

module Common
  module AddressMethods
    def to_s
      [yield(:next), yield(:receiver).address].join("; ")
    end
  end
end

class Student < Struct.new(:first_name, :last_name, :address, :university)
  def to_s
    [first_name, last_name].join(" ")
  end

  module EducationMethods
    def to_s
      [yield(:next), yield(:receiver).university].join("; ")
    end
  end

  include Common
  include EducationMethods => :education
  include AddressMethods => :address
end

class University < Struct.new(:name, :address)
  def to_s
    name
  end

  include Common
  include AddressMethods => :address
end

module Fibonacci
  module ClassMethods
    def compute(fixnum)
      if fixnum == 1 or fixnum == 0
        fixnum
      elsif fixnum < 0
        raise ArgumentError, "Fibonacci not defined for negative numbers"
      else
        compute(fixnum - 1) + compute(fixnum - 2)
      end
    end

    module LoggingMethods
      def compute(fixnum)
        print "."
        yield(:next, fixnum)
      end
    end

    module CacheMethods
      def cache
        @cache ||={}
      end

      def compute(fixnum)
        cache[fixnum] ||= yield(:next, fixnum)
      end
    end
  end

  self.extend(ClassMethods)
  self.extend ClassMethods::CacheMethods    => :cache,
              ClassMethods::LoggingMethods  => :logging
end

puts
puts "Example on Instance Side"
module Example
  module ClassMethods
    def show
      me = Student.new("Gregor", "Schmidt", "Berlin")
      hpi = University.new("HPI", "Potsdam")
      me.university = hpi
      print(me)
    end

    def print(me)
      puts me
      with_addresses do
        puts me
      end
      with_education do
        puts me
      end
      with_education do
        with_addresses do
          puts me
        end
      end
    end

    def with_addresses
      ContextR::with_layers :address do
        yield
      end
    end

    def with_education
      ContextR::with_layers :education do
        yield
      end
    end
  end
  self.extend(ClassMethods)
end
Example.show

puts
puts "Example with changed instance methods after behaviour registration"
class Student
  def to_s
    [first_name, last_name].reverse.join(", ")
  end
end
Example.show

puts
puts "Example with changed behaviour methods after their registration"
module Student::EducationMethods
  def to_s
    [yield(:next), yield(:receiver).university].join("\n - ")
  end
end
Example.show

puts
puts "Example on Class Side"
class ExampleClassSide
  module ClassMethods
    def show(int = 3)
      puts Fibonacci.compute(int)
      ContextR::with_layers :cache do
        puts Fibonacci.compute(int)
      end
      ContextR::with_layers :logging do
        puts Fibonacci.compute(2 * int)

        ContextR::with_layers :cache do
          puts Fibonacci.compute(2 * int)
        end
      end
    end
  end
  self.extend(ClassMethods)
end
ExampleClassSide.show
