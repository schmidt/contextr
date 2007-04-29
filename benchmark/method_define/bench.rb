require 'benchmark'

class A
  def standard_define
    true
  end
  def standard_redefine
    true
  end
  def redefine_with_block
    true
  end
  def redefine_with_string
    true
  end
end

class A
  def standard_redefine
    true
  end
end

A.class_eval %Q{
  def redefine_with_string
    true
  end
} 

A.class_eval do
  define_method( :redefine_with_block ) do ||
    true
  end
end

n = 5_000_000
Benchmark.bm(30) do | b |
  instance = A.new
  b.report( "standard_define" ) do
    n.times { instance.standard_define }
  end

  instance = A.new
  b.report( "standard_redefine" ) do
    n.times { instance.standard_redefine }
  end

  instance = A.new
  b.report( "redefine_with_string" ) do
    n.times { instance.redefine_with_string }
  end
  instance = A.new
  b.report( "redefine_with_block" ) do
    n.times { instance.redefine_with_block }
  end
end

__END__

