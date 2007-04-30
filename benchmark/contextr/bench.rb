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
Ordinary:             0.410000   0.000000   0.410000 (  0.406774)
Once (w/o):           6.080000   0.010000   6.090000 (  6.148515)
Once (ctx):          16.560000   0.020000  16.580000 ( 16.700489)
Twice (w/o):          6.100000   0.010000   6.110000 (  6.113543)
Twice (ctx):         18.620000   0.010000  18.630000 ( 18.686153)
Wrapped (w/o):        6.140000   0.010000   6.150000 (  6.152476)
Wrapped (ctx):       29.740000   0.030000  29.770000 ( 29.816371)
All wrappers (ctx):  37.250000   0.040000  37.290000 ( 37.344437)

n = 100_000
                          user     system      total        real
Ordinary:             0.040000   0.000000   0.040000 (  0.040648)
Once (w/o):           0.610000   0.000000   0.610000 (  0.613713)
Once (ctx):           1.660000   0.000000   1.660000 (  1.689277)
Twice (w/o):          0.610000   0.000000   0.610000 (  0.608093)
Twice (ctx):          1.870000   0.010000   1.880000 (  1.918604)
Wrapped (w/o):        0.600000   0.000000   0.600000 (  0.605630)
Wrapped (ctx):        2.960000   0.010000   2.970000 (  2.979563)
All wrappers (ctx):   3.750000   0.000000   3.750000 (  3.761805)
