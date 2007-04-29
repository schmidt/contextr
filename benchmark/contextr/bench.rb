require 'benchmark'
require File.dirname( __FILE__ ) + '/../../contextr'

class Foo
  layer :one
  layer :two
  
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

#  one.claim :claimed
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
end



__END__
n = 100_000

