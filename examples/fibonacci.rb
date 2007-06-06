require "rubygems"
require "contextr" 

require 'test/unit'
require 'benchmark'

class Fibonacci
  class << self
    def compute fixnum
      if fixnum == 1 or fixnum == 0
        fixnum
      elsif fixnum < 0
        raise ArgumentError, "Fibonacci not defined for negative numbers"
      else
        compute(fixnum - 1) + compute(fixnum - 2)
      end
    end
  
    layer :fib_before_after, :fib_around
    attr_accessor :cache

    fib_before_after.before :compute do | nature |
      self.cache ||= {}
      if self.cache.key? nature.arguments.first
        nature.break! self.cache[nature.arguments.first]
      end
    end

    fib_before_after.after :compute do | nature |
      self.cache[nature.arguments.first] = nature.return_value
    end
    
    fib_around.around :compute do | nature |
      self.cache ||= {}
      if self.cache.key? nature.arguments.first
        nature.return_value = self.cache[nature.arguments.first]
      else
        nature.call_next
        self.cache[nature.arguments.first] = nature.return_value
      end
    end
  end
end

class Fixnum
  def fibonacci
    if self == 1 or self == 0
      self
    elsif self < 0
      raise ArgumentError, "Fibonacci not defined for negative numbers"
    else
      old_fib, fib = 0, 1
      for i in 2..self
        fib, old_fib = old_fib + fib, fib
      end
      fib
    end
  end
end

class FibonacciTest < Test::Unit::TestCase
  def setup
    Fibonacci.cache = {}
  end
  
  def test_basic_function
    Benchmark.bm(20) do |x|
      x.report("Recursive:") {
        assert_equal       0, Fibonacci.compute(  0 )
        assert_equal       1, Fibonacci.compute(  1 )
        assert_equal       1, Fibonacci.compute(  2 )
        assert_equal      55, Fibonacci.compute( 10 )
        assert_equal    6765, Fibonacci.compute( 20 )
        # The following are too hard for the simple solution
        assert_equal  75_025, 25.fibonacci
        assert_equal 9227465, 35.fibonacci
        assert_equal 280571172992510140037611932413038677189525,
                              200.fibonacci
        assert_equal 176023680645013966468226945392411250770384383304492191886725992896575345044216019675,
                              400.fibonacci
      }
    end
  end
  
  def test_layered_function_with_before_after
    Benchmark.bm(20) do |x|
      x.report("Layered Pre/Post:") {
        ContextR.with_layers :fib_before_after do
          assert_equal       0, Fibonacci.compute(  0 )
          assert_equal       1, Fibonacci.compute(  1 )
          assert_equal       1, Fibonacci.compute(  2 )
          assert_equal      55, Fibonacci.compute( 10 )
          assert_equal    6765, Fibonacci.compute( 20 )
          assert_equal  75_025, Fibonacci.compute( 25 )
          assert_equal 9227465, Fibonacci.compute( 35 )
          assert_equal 280571172992510140037611932413038677189525,
                                Fibonacci.compute( 200 )
          assert_equal 176023680645013966468226945392411250770384383304492191886725992896575345044216019675,
          Fibonacci.compute( 400 )
        end
      }
    end
  end
  
  def test_layered_function_with_around
    Benchmark.bm(20) do |x|
      x.report("Layered Wrap:") {
        ContextR.with_layers :fib_around do
          assert_equal       0, Fibonacci.compute(  0 )
          assert_equal       1, Fibonacci.compute(  1 )
          assert_equal       1, Fibonacci.compute(  2 )
          assert_equal      55, Fibonacci.compute( 10 )
          assert_equal    6765, Fibonacci.compute( 20 )
          assert_equal  75_025, Fibonacci.compute( 25 )
          assert_equal 9227465, Fibonacci.compute( 35 )
          assert_equal 280571172992510140037611932413038677189525,
                                Fibonacci.compute( 200 )
          assert_equal 176023680645013966468226945392411250770384383304492191886725992896575345044216019675,
                                Fibonacci.compute( 400 )
        end
      }
    end
  end
end
