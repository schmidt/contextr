require 'benchmark'
require File.dirname( __FILE__ ) + '/../../lib/contextr'

class Foo
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

  in_layer :once do
    def once
      true
    end
    def twice 
      true
    end
  end

  in_layer :two do
    def twice
      true
    end
  end
end

f = Foo.new

n = 100_000
Benchmark.bmbm(20) do |x|
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
end

__END__
n = 100_000 (bmbm to warm up the jvm)

ruby 1.8.6
                          user     system      total        real
Ordinary:             0.040000   0.000000   0.040000 (  0.041294)
Once (w/o):           1.030000   0.010000   1.040000 (  1.043971)
Once (ctx):           1.540000   0.000000   1.540000 (  1.598743)
Twice (w/o):          1.030000   0.010000   1.040000 (  1.055684)
Twice (ctx):          2.780000   0.010000   2.790000 (  2.839568)

jruby -O -J-server 1.0.2
                          user     system      total        real
Ordinary:             0.108000   0.000000   0.108000 (  0.108000)
Once (w/o):           2.336000   0.000000   2.336000 (  2.335000)
Once (ctx):           3.390000   0.000000   3.390000 (  3.390000)
Twice (w/o):          2.439000   0.000000   2.439000 (  2.439000)
Twice (ctx):          5.191000   0.000000   5.191000 (  5.190000)
