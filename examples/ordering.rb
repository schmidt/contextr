require File.dirname(__FILE__) + "/../lib/contextr.rb"

class Test
  def test
    puts "base_method"
  end

  module FooMethods
    def test
      puts "foo_pre"
      yield(:next)
      puts "foo_post"
    end
  end
  module BarMethods
    def test
      puts "bar_pre"
      yield(:next)
      puts "bar_post"
    end
  end
  include FooMethods => :test
  include BarMethods => :test
end
ContextR::with_layer :test do
  Test.new.test
end
