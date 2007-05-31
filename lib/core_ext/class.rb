# ContextR extends Class to allow the definition of context-dependent behaviour.
# 
# After registering a layer within in class, it is accessable via its name,
# to add behaviour to methods.
class Class 
  # register a layer to be used within a class body
  def layer(*layer_keys)
    layer_keys.each do | layer_key |
      layer_key = layer_key.to_s.downcase.to_sym
      layer_name = ContextR::layerize(layer_key)
      layer = ContextR.layer_by_name(layer_name)
      
      define_private_class_method(layer_key) do
        layer.in(self)
      end
    end
    nil
  end

protected
  def define_private_class_method(symbol, &block) # :nodoc:
    (class << self; self; end).instance_eval do
      define_method(symbol, block)
      private symbol 
    end
  end
end
