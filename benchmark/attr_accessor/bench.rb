require 'benchmark'
require File.dirname( __FILE__ ) + '/../../contextr'

class FooWithInitializer
  attr_accessor :bar
  def initialize
    self.bar = true
  end
end
class FooWithCustomGetter
  attr_writer :bar
  def bar
    @bar ||= true
  end
end
class FooWithAttrAccessorWithDefaultSetter
  attr_accessor_with_default_setter :bar do
    true
  end
end

init         = 1_000_000
first_access =   100_000
gett         = 4_000_000

puts
puts "Initialization"
Benchmark.bm( 33 ) do | b |
  b.report( "initializer" ) do
    init.times { FooWithInitializer.new }
  end

  b.report( "custom getter" ) do
    init.times { FooWithCustomGetter.new }
  end

  b.report( "attr_accessor_with_default_setter" ) do
    init.times { FooWithAttrAccessorWithDefaultSetter.new }
  end
end

puts 
puts "Access default for the first time"
Benchmark.bm( 33 ) do | b |
  foos = Array.new( first_access ) do
    FooWithInitializer.new
  end
  b.report( "initializer" ) do
    foos.each do | foo | 
      foo.bar
    end
  end

  foos = Array.new( first_access ) do
    FooWithCustomGetter.new
  end
  b.report( "custom getter" ) do
    foos.each do | foo | 
      foo.bar
    end
  end

  foos = Array.new( first_access ) do
    FooWithAttrAccessorWithDefaultSetter.new
  end
  b.report( "attr_accessor_with_default_setter" ) do
    foos.each do | foo | 
      foo.bar
    end
  end
end

puts
puts "Access value"
Benchmark.bm( 33 ) do | b |
  b.report( "initializer" ) do
    foo = FooWithInitializer.new
    gett.times { foo.bar }
  end

  b.report( "custom getter" ) do
    foo = FooWithCustomGetter.new
    gett.times { foo.bar }
  end

  b.report( "attr_accessor_with_default_setter" ) do
    foo = FooWithAttrAccessorWithDefaultSetter.new
    gett.times { foo.bar }
  end
end

__END__

Initialization
                                       user     system      total        real
initializer                        2.050000   0.020000   2.070000 (  2.076407)
custom getter                      0.700000   0.000000   0.700000 (  0.707666)
attr_accessor_with_default_setter  0.660000   0.000000   0.660000 (  0.667314)

Access default for the first time
                                       user     system      total        real
initializer                        0.040000   0.000000   0.040000 (  0.042530)
custom getter                      0.110000   0.010000   0.120000 (  0.130342)
attr_accessor_with_default_setter  1.970000   0.030000   2.000000 (  2.040054)

Access value
                                       user     system      total        real
initializer                        1.240000   0.010000   1.250000 (  1.315070)
custom getter                      2.090000   0.000000   2.090000 (  2.203422)
attr_accessor_with_default_setter  1.260000   0.010000   1.270000 (  1.306373)
