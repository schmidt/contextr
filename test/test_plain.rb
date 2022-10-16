require 'test/unit'
require File.dirname(__FILE__) + '/../lib/contextr'

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

class TestPlain < Test::Unit::TestCase
  def test_001
    assert_equal("a1", $c1.to_s)
    assert_equal("a2", $c2.to_s)
  end

  def test_002
    ContextR.with_layer :b do
      assert_equal("a1 (b1)", $c1.to_s)
      assert_equal("a2 (b2)", $c2.to_s)
    end
  end

  def test_003
    assert_equal("a1", $c1.to_s)
    assert_equal("a2", $c2.to_s)
  end

  def test_004
    ContextR.with_layer :c do
      assert_equal("a2; a1", $c2.to_s)
    end
  end

  def test_005
    ContextR.with_layer :b, :c do
      assert_equal("a2 (b2); a1 (b1)", $c2.to_s)
    end
  end

  def test_006
    ContextR::with_layer :b do
      ContextR.with_layer :c do
        assert_equal("a2 (b2); a1 (b1)", $c2.to_s)

        ContextR.without_layer :c do
          assert_equal("a2 (b2)", $c2.to_s)
        end

        assert_equal("a2 (b2); a1 (b1)", $c2.to_s)
      end
    end
  end

  if RUBY_VERSION =~ /1\.8/
    def test_007
      assert_equal(["to_s"], C1.in_layer(:b).instance_methods)
    end
  end
  if RUBY_VERSION =~ /1\.9/
    def test_007
      assert_equal([:to_s], C1.in_layer(:b).instance_methods)
    end
  end
end
