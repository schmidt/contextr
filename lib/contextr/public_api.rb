module ContextR
  module ClassMethods
    include MutexCode

    # allows the explicit activation of layers within a block context
    #
    #   ContextR::with_layers(:foo, :bar) do
    #     ContextR::current_layers            # => [:default, :foo, :bar]
    #
    #     ContextR::with_layers(:baz) do
    #       ContextR::current_layers          # => [:default, :foo, :bar, :baz]
    #     end
    #
    #   end
    # 
    # :call-seq:
    #   with_layers(layer_name, ...) { ... }
    #
    def with_layers(*layer_symbols, &block)
      layers = layer_symbols.collect do | layer_symbol |
        layer_by_symbol(layer_symbol)
      end
      Dynamic.let({ :layers => Dynamic[:layers] | layers }, &block)
    end
    alias with_layer with_layers

    # allows the explicit deactivation of layers within a block context
    # 
    #   ContextR::with_layers(:foo, :bar) do
    #     ContextR::current_layers            # => [:default, :foo, :bar]
    #
    #     ContextR::without_layers(:foo) do
    #       ContextR::current_layers          # => [:default, :bar]
    #     end
    #
    #   end
    #
    # :call-seq:
    #   without_layers(layer_name, ...) { ... }
    #
    def without_layers(*layer_symbols, &block)
      layers = layer_symbols.collect do | layer_symbol |
        layer_by_symbol(layer_symbol)
      end
      Dynamic.let({ :layers => Dynamic[:layers] - layers }, &block)
    end
    alias without_layer without_layers

    def layers
      Dynamic[:layers]
    end

    def layer_symbols
      layers.collect { | layer | symbol_by_layer(layer) }
    end
  end
end

