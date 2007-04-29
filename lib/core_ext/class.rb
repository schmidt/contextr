class Class 
  def layer( *layer_keys )
    layer_keys.each do | layer_key |
      layer_key = layer_key.to_s.downcase.to_sym
      layer_name = ContextR::layerize( layer_key )
      layer = ContextR.layer_by_name( layer_name )
      layer_in_class = ContextR::LayerInClass.new( self, layer )

      define_private_class_method( layer_key ) do
        layer_in_class
      end
    end
    
    nil
  end

protected
  def define_private_class_method( symbol, &block )
    (class << self; self; end).instance_eval do
      define_method( symbol, block )
      private symbol 
    end
  end
end
