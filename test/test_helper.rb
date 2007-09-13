require 'test/unit'
require File.dirname(__FILE__) + '/../lib/contextr'

unless Object.const_defined?("ExampleTest")
  module ExampleTest
    module ObjectExtension
      def test_class(name)
        $latest_test_class = Class.new(Test::Unit::TestCase)
        $latest_test_case  = 0
        Object.const_set(name, $latest_test_class) 
      end

      def example(&block)
        $latest_test_class.class_eval do
          define_method("test_%03d" % ($latest_test_case += 1), &block)
        end
      end
    end
    
    module TestExtension
      def assert_to_s(expected, actual)
        assert_equal(expected, actual.to_s)
      end

      def output_of(object)
        Output.new(object, self)
      end

      class Output
        attr_accessor :object, :test_class
        def initialize(object, test_class)
          self.object = object
          self.test_class = test_class 
        end
        def ==(string)
          test_class.assert_equal(string, object.to_s)
        end
      end
    end
  end

  class Test::Unit::TestCase
    include ExampleTest::TestExtension
  end
  class Object 
    include ExampleTest::ObjectExtension
  end
end
