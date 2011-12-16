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
      layers_being_activated = layers - active_layers_as_classes
      layers_being_activated.each { |l| l.activated }

      return_value = layered_do(layers | active_layers_as_classes, block)

      layers_being_activated.each { |l| l.deactivated }
      return_value
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
      layers_being_deactivated = layers & active_layers_as_classes
      layers_being_deactivated.each { |l| l.deactivated }

      return_value = layered_do(active_layers_as_classes - layers, block)

      layers_being_deactivated.each { |l| l.activated }
      return_value
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

    # returns the layer, defined by the given name. If passed a block, it will
    # instance_eval it on the layer and return its value instead. The latter
    # may be used to define the activated and deactived methods for a layer.
    #
    #   ContextR::layer(:log) do
    #     def logger
    #       @logger ||= Logger.new
    #     end
    #     def activated
    #       logger.log("Logging active")
    #     end
    #     def deactivated
    #       logger.log("Logging inactive")
    #     end
    #   end
    #
    #   # will call activated before executing the block
    #   # and deactivated afterwards
    #   ContextR::with_layer(:log) do
    #     1 + 1
    #   end
    #
    def layer(name, &block)
      if block_given?
        layer_by_symbol(name).instance_eval(&block)
      else
        layer_by_symbol(name)
      end
    end
  end
  self.extend(PublicApi)
end

