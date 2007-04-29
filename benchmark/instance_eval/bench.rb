require 'benchmark'

class A
  def a
    true
  end
end

n = 1_000_000
Benchmark.bm(30) do | b |
  instance = A.new
  b.report( "simple call" ) do
    n.times { instance.a }
  end

  instance = A.new
  block = lambda { true }
  b.report( "instance_eval with block" ) do
    n.times { instance.instance_eval( &block ) }
  end

  instance = A.new
  string = "true"
  b.report( "instance_eval with string" ) do
    n.times { instance.instance_eval( string ) }
  end

  method = A.instance_method( :a )
  instance = A.new
  bound_method = method.bind( instance )
  b.report( "bound method" ) do
    n.times { bound_method.call }
  end

  method = A.instance_method( :a )
  instance = A.new
  b.report( "bind method each time" ) do
    n.times { method.bind( instance ).call }
  end
end


__END__
ruby
                                    user     system      total        real
simple call                     0.420000   0.000000   0.420000 (  0.416984)
instance_eval with block        1.080000   0.000000   1.080000 (  1.084615)
instance_eval with string       3.060000   0.010000   3.070000 (  3.075162)
bound method                    0.490000   0.000000   0.490000 (  0.498444)
bind method each time           1.150000   0.000000   1.150000 (  1.157281)

ruby_yarv
                                    user     system      total        real
simple call                     0.250000   0.000000   0.250000 (  0.253682)
instance_eval with block        1.570000   0.010000   1.580000 (  1.578436)
instance_eval with string      12.100000   0.050000  12.150000 ( 12.387249)
bound method                    0.450000   0.000000   0.450000 (  0.447701)
bind method each time           1.080000   0.010000   1.090000 (  1.087543)

jruby
                                    user     system      total        real
simple call                     1.401000   0.000000   1.401000 (  1.401000)
instance_eval with block        2.279000   0.000000   2.279000 (  2.279000)
instance_eval with string      37.149000   0.000000  37.149000 ( 37.149000)
bound method                    1.731000   0.000000   1.731000 (  1.731000)
bind method each time           4.345000   0.000000   4.345000 (  4.346000)
