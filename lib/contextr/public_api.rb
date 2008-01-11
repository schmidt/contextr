module ContextR
  module PublicApi 
    # allows the explicit activation of layers within a block context
    #
    #   ContextR::with_layers(:foo, :bar) do
    #     ContextR::active_layers            # => [:default, :foo, :bar]
    #
    #     ContextR::with_layers(:baz) do
    #       ContextR::active_layers          # => [:default, :foo, :bar, :baz]
    #     end
    #
    #   end
    # 
    # :call-seq:
    #   with_layers(layer_name, ...) { ... }
    #
    def with_layers(*layer_symbols, &block)
      layers = layer_symbols.collect do |layer_symbol|
        layer_by_symbol(layer_symbol)
      end.reverse
      layered_do(layers | active_layers_as_classes, block)
    end
    alias with_layer with_layers

    # allows the explicit deactivation of layers within a block context
    # 
    #   ContextR::with_layers(:foo, :bar) do
    #     ContextR::active_layers            # => [:default, :foo, :bar]
    #
    #     ContextR::without_layers(:foo) do
    #       ContextR::active_layers          # => [:default, :bar]
    #     end
    #
    #   end
    #
    # :call-seq:
    #   without_layers(layer_name, ...) { ... }
    #
    def without_layers(*layer_symbols, &block)
      layers = layer_symbols.collect do |layer_symbol|
        layer_by_symbol(layer_symbol)
      end
      layered_do(active_layers_as_classes - layers, block)
    end
    alias without_layer without_layers

    # returns all currently active layers in their activation order
    def active_layers
      active_layers_as_classes.collect { |layer| symbol_by_layer(layer) }
    end

    # returns all layers that where defined, but are not neccessarily active
    def layers
      layers_as_classes.collect { |layer| symbol_by_layer(layer) }
    end

  end
  self.extend(PublicApi)
end

