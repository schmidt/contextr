require 'rubygems'
require 'test/unit'
require 'markaby'
require 'ruby2ruby'
require 'maruku'

require File.dirname(__FILE__) + '/../lib/contextr'

unless Object.const_defined?("ExampleTest")
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
end



unless Object.const_defined?("LiterateMarkabyTest")
  module LiterateMarkabyTest
    TARGET_DIR = File.dirname(__FILE__) + "/../website/test/"
    module ObjectExtension
      def test(name, &block)
        mab = Markaby::Builder.new

        mab.test_class = Class.new(Test::Unit::TestCase)
        mab.latest_test_case = 0

        Object.const_set(name, mab.test_class) 
        mab.xhtml_strict do
          head do
            title { name }
          end
          body do
            h1 { name }
            div(&block) 
          end
        end

        Dir.mkdir(TARGET_DIR) unless File.directory?(TARGET_DIR)
        File.open(TARGET_DIR + name.to_s.underscore + ".html", "w") do |f|
          f.puts mab.to_s
        end
      end
    end

    module MarkabyBuilderExtension
      attr_accessor :test_class, :latest_test_case
      def output(&block)
        block.call
        self.pre(block.to_ruby.gsub(/^proc \{\n(.*)\n\}$/m, '\1'))
      end
      def example(&block)
        name = "test_%03d" % (self.latest_test_case += 1)
        test_class.class_eval do
          define_method(name, &block)
        end
        self.pre(block.to_ruby.gsub(/^proc \{\n(.*)\n\}$/m, '\1'))
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

#  class Test::Unit::TestCase
#    include LiterateMarkabyTest::TestExtension
#  end
  class Object 
    include LiterateMarkabyTest::ObjectExtension
  end
  class Markaby::Builder
    include LiterateMarkabyTest::MarkabyBuilderExtension
  end
end


