module ExampleTest
  module ClassMethods
    attr_accessor :latest_test_class
    attr_accessor :latest_test_case
  end
  extend ClassMethods

  module ObjectExtension
    def test_class(name)
      ExampleTest::latest_test_class = Class.new(Test::Unit::TestCase)
      ExampleTest::latest_test_case  = 0
      Object.const_set(name, ExampleTest::latest_test_class) 
    end

    def example(&block)
      ExampleTest::latest_test_class.class_eval do
        define_method("test_%03d" % (ExampleTest::latest_test_case += 1), 
                      &block)
      end
    end
  end
  
  module TestExtension
    def assert_to_s(expected, actual)
      assert_equal(expected, actual.to_s)
    end

    def result_of(object)
      Result.new(object, self)
    end

    def output_of(object)
      Output.new(object, self)
    end

    class Result 
      attr_accessor :object, :test_class
      def initialize(object, test_class)
        self.object = object
        self.test_class = test_class 
      end
      def ==(string)
        test_class.assert_equal(string, object)
      end
    end
    class Output < Result
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
