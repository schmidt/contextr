require File.dirname(__FILE__) + "/../lib/contextr.rb"

class AnyClass
  def test
    puts "base_method"
  end

  module InnerMethods
    def test
      puts "inner_pre"
      yield(:next)
      puts "inner_post"
    end
  end
  include InnerMethods => :test

  module OuterMethods
    def test
      puts "outer_pre"
      yield(:next)
      puts "outer_post"
    end
  end
  include OuterMethods => :test
end

ContextR::with_layer :test do
  AnyClass.new.test
end
