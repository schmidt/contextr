require 'benchmark'
require File.dirname( __FILE__ ) + '/../../contextr'

class Foo
  layer :one
  layer :two
  layer :full
  
  def ordinary
    true
  end

  def once
    true
  end

  def twice
    true
  end

  def wrapped
    true
  end

  def full
    true
  end

  def claimed
    true
  end

  one.pre :once do
    true
  end

  one.pre :twice do
    true
  end

  two.pre :twice do
    true
  end

  one.wrap :wrapped do |n|
    n.call_next
    true
  end

  full.pre :full do
    true
  end
  full.around :full do | n |
    n.call_next
  end
  full.post :full do
    true
  end

#  one.claim :claimed
end

class MockObject
  def method_missing method_name, *arguments
    self.class.class_eval %Q{
      def #{method_name}
        true
      end
    }
  end
end


f = Foo.new

n = 100_000
Benchmark.bm(20) do |x|
  x.report("Ordinary:") {
    n.times { f.ordinary }
  }

  x.report("Once (w/o):") {
    n.times { f.once }
  }

  x.report("Once (ctx):") {
    ContextR.with_layers :one do
      n.times { f.once }
    end
  }

  x.report("Twice (w/o):") {
    n.times { f.twice }
  }

  x.report("Twice (ctx):") {
    ContextR.with_layers :one, :two do
      n.times { f.twice }
    end
  }

  x.report("Wrapped (w/o):") {
    n.times { f.wrapped }
  }

  x.report("Wrapped (ctx):") {
    ContextR.with_layers :one, :two do
      n.times { f.wrapped }
    end
  }

#  x.report("Claimed (ctx):") {
#    ContextR.with_layers :one do
#      n.times { f.claimed }
#    end
#  }

  x.report("All wrappers (ctx):") {
    ContextR.with_layers :full do
      n.times { f.full }
    end
  }
end



__END__
n = 1_000_000
                          user     system      total        real
Ordinary:             0.410000   0.000000   0.410000 (  0.404385)
Once (w/o):           5.990000   0.000000   5.990000 (  6.011220)
Once (ctx):          15.330000   0.040000  15.370000 ( 15.654238)
Twice (w/o):          6.010000   0.020000   6.030000 (  6.181048)
Twice (ctx):         17.540000   0.050000  17.590000 ( 17.916814)
Wrapped (w/o):        5.980000   0.000000   5.980000 (  6.003156)
Wrapped (ctx):       27.200000   0.080000  27.280000 ( 27.709265)
All wrappers (ctx):  36.210000   0.040000  36.250000 ( 36.396985)

n = 100_000
                          user     system      total        real
Ordinary:             0.040000   0.010000   0.050000 (  0.040774)
Once (w/o):           0.610000   0.000000   0.610000 (  0.607807)
Once (ctx):           1.520000   0.000000   1.520000 (  1.530119)
Twice (w/o):          0.590000   0.000000   0.590000 (  0.603521)
Twice (ctx):          1.750000   0.000000   1.750000 (  1.750641)
Wrapped (w/o):        0.570000   0.000000   0.570000 (  0.573221)
Wrapped (ctx):        2.720000   0.010000   2.730000 (  2.731870)
All wrappers (ctx):   3.620000   0.000000   3.620000 (  3.626157)

