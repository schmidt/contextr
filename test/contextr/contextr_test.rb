require File.dirname(__FILE__) + '/../test_helper'

class UnitContextRFoo
  layer :pre, :post, :wrap
  layer :stop_wrap, :stop_pre, :stop_post
  layer :order_wrap, :order_pre, :order_post
  layer :group_pre, :group_post
  
  def bar( sum )
    sum + 0b00100
  end

  pre.pre :bar do | nature |
    nature.arguments[ 0 ] += 0b00010
  end

  post.post :bar do | nature |
    nature.return_value += 0b01000
  end

  wrap.wrap :bar do | nature |
    nature.arguments[ 0 ] += 0b00001
    nature.call_next
    nature.return_value += 0b10000
  end
  
  stop_pre.pre :bar do | nature |
    nature.break! nature.arguments[0]
  end
  stop_wrap.wrap :bar do | nature |
    nature.break! nature.arguments[0]
  end
  stop_post.post :bar do | nature |
    nature.break! nature.return_value
  end
  
  order_pre.pre :bar do | nature |
    nature.break! :pre
  end
  
  order_post.post :bar do | nature |
    nature.break! :post
  end
  
  order_wrap.wrap :bar do | nature |
    nature.break! :wrap
  end
  
  group_pre.pre :bar do | nature |
    nature.return_value = :pre
  end
  
  group_pre.pre :bar do | nature |
    nature.break! nature.return_value
  end

  group_post.post :bar do | nature |
    nature.return_value = :post
  end
  
  group_post.post :bar do | nature |
    nature.break! nature.return_value
  end
end


class ContextRTest < Test::Unit::TestCase
  def setup
    @foo = UnitContextRFoo.new
  end
  
  def test_01_layer_activiation
    assert_equal 0b00100, @foo.bar( 0 )
    
    ContextR.with_layers :wrap do
      assert_equal 0b10101, @foo.bar( 0 )
      
      ContextR.without_layers :wrap do
        assert_equal 0b00100, @foo.bar( 0 )
      end
      
      assert_equal 0b10101, @foo.bar( 0 )
    end
    
    assert_equal 0b00100, @foo.bar( 0 )
  end
  
  def test_02_cascading_layers
    assert_equal 0b00100, @foo.bar( 0 )
    
    ContextR.with_layers :pre do
      assert_equal 0b00110, @foo.bar( 0 )
      
      ContextR.with_layers :post do
        assert_equal 0b01110, @foo.bar( 0 )
        
        ContextR.with_layers :wrap do
          assert_equal 0b11111, @foo.bar( 0 )
        end
        
        assert_equal 0b01110, @foo.bar( 0 )
      end
      
      assert_equal 0b00110, @foo.bar( 0 )
    end
    
    assert_equal 0b00100, @foo.bar( 0 )
  end
  
  def test_03_breaking_behaviour
    ContextR.with_layers :pre, :post, :stop_wrap do
      assert_equal 0b00010, @foo.bar( 0 )
    end
  end
  
  def test_04_ordering_by_selectors
    # pre before post
    ContextR.with_layers :order_pre, :order_post do
      assert_equal :pre, @foo.bar( 0 )
    end
    # pre before wrap
    ContextR.with_layers :order_wrap, :order_pre do
      assert_equal :pre, @foo.bar( 0 )
    end
    # wrap before body
    ContextR.with_layers :order_wrap do
      assert_equal :wrap, @foo.bar( 0 )
    end
    # wrap before post
    ContextR.with_layers :order_wrap, :order_post do
      assert_equal :wrap, @foo.bar( 0 )
    end
    # To be completed...
  end
  
  def test_05_ordering_by_layers
    ContextR.with_layers :wrap, :stop_wrap do
      assert_equal 0b00000, @foo.bar( 0 )
    end
    ContextR.with_layers :stop_wrap, :wrap do
      assert_equal 0b00001, @foo.bar( 0 )
    end
    ContextR.with_layers :pre, :stop_pre do
      assert_equal 0b00000, @foo.bar( 0 )
    end
    ContextR.with_layers :stop_pre, :pre do
      assert_equal 0b00010, @foo.bar( 0 )
    end
    ContextR.with_layers :post, :stop_post do
      assert_equal 0b01100, @foo.bar( 0 )
    end
    ContextR.with_layers :stop_post, :post do
      assert_equal 0b00100, @foo.bar( 0 )
    end
  end
  
  def test_06_ordering_within_groups
    ContextR.with_layers :group_pre do
      assert_equal nil, @foo.bar( 0 )
    end
    ContextR.with_layers :group_post do
      assert_equal :post, @foo.bar( 0 )
    end
  end
end
