require File.dirname(__FILE__) + "/test_helper.rb"
test_class(:TestPlain)

class C1 < Struct.new(:a, :b)
  def to_s
    a
  end
end
class C2 < Struct.new(:a, :b, :c1)
  def to_s
    a
  end
end

class C1
  in_layer :b do
    def to_s
      "#{super} (#{yield(:receiver).b})"
    end
  end
end
class C2
  in_layer :b do
    def to_s
      "#{super} (#{yield(:receiver).b})"
    end
  end
  in_layer :c do
    def to_s
      "#{super}; #{yield(:receiver).c1}"
    end
  end
end

$c1 = C1.new("a1", "b1")
$c2 = C2.new("a2", "b2", $c1)

example do
  output_of($c1) == "a1"
  output_of($c2) == "a2"
end

example do
  ContextR.with_layer :b do 
    output_of($c1) == "a1 (b1)"
    output_of($c2) == "a2 (b2)"
  end
end

example do
  output_of($c1) == "a1"
  output_of($c2) == "a2"
end

example do
  ContextR.with_layer :c do 
    output_of($c2) == "a2; a1"
  end
end

example do
  ContextR.with_layer :b, :c do 
    output_of($c2) == "a2 (b2); a1 (b1)"
  end
end

example do
  ContextR::with_layer :b do
    ContextR.with_layer :c do 
      output_of($c2) == "a2 (b2); a1 (b1)"

      ContextR.without_layer :c do 
        output_of($c2) == "a2 (b2)"
      end

      output_of($c2) == "a2 (b2); a1 (b1)"
    end
  end
end

example(1.8) do
  assert_equal(["to_s"], C1.in_layer(:b).instance_methods)
end
example(1.9) do
  assert_equal([:to_s], C1.in_layer(:b).instance_methods)
end
