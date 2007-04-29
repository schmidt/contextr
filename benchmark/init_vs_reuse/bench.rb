require 'benchmark'
require File.dirname( __FILE__ ) + '/../../ext/method_nature'

n = 1_000_000
Benchmark.bm(30) do | b |
  arguments = [ 1, 2, 3 ]
  b.report( "initialize" ) do
    n.times { MethodNature.new( arguments, nil, false, nil ) }
  end

  nature = MethodNature.new( arguments, nil, false )
  b.report( "reset independently" ) do
    n.times { 
      nature.arguments = arguments 
      nature.return_value = nil 
      nature.break = false 
      nature.block = nil 
    }
  end

  nature = MethodNature.new( arguments, nil, false )
  b.report( "reset by constructor" ) do
    n.times { nature.reset( [ arguments, nil, false, nil ] ) }
  end
end

__END__
