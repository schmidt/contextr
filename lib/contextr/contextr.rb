module ContextR

  # This module is mixed into ContextR module, so that all public methods
  # are available via
  #   ContextR::current_layers
  #   ContextR::with_layers( layer_name, ... ) { ... }
  #   ContextR::without_layers( layer_name, ... ) { ... }
  module ClassMethods
    # allows the explicit activation of layers within a block context
    #
    #   ContextR::with_layers( :foo, :bar ) do
    #     ContextR::current_layers            # => [:default, :foo, :bar]
    #
    #     ContextR::with_layers( :baz ) do
    #       ContextR::current_layers          # => [:default, :foo, :bar, :baz]
    #     end
    #
    #   end
    # 
    # :call-seq:
    #   with_layers( layer_name, ... ) { ... }
    #
    def with_layers( *layer_symbols, &block )
      layers = layer_symbols.collect do | layer_symbol |
        ContextR.layer_by_name( ContextR.layerize( layer_symbol ) )
      end
      Dynamic.let( { :layers => Dynamic[:layers] | layers }, &block )
    end
    alias with_layer with_layers

    # allows the explicit activation of layers
    # 
    #   ContextR::activate_layers( :foo, :bar )
    #   ContextR::current_layers            # => [:default, :foo, :bar]
    #
    # :call-seq:
    #   deactivate_layers( layer_name, ... )
    #
    def activate_layers( *layer_symbols )
      layers = layer_symbols.collect do | layer_symbol |
        ContextR.layer_by_name( ContextR.layerize( layer_symbol ) )
      end
      Dynamic[:layers] |= layers
    end
    alias activate_layer activate_layers

    # allows the explicit deactivation of layers within a block context
    # 
    #   ContextR::with_layers( :foo, :bar ) do
    #     ContextR::current_layers            # => [:default, :foo, :bar]
    #
    #     ContextR::without_layers( :foo ) do
    #       ContextR::current_layers          # => [:default, :bar]
    #     end
    #
    #   end
    #
    # :call-seq:
    #   without_layers( layer_name, ... ) { ... }
    #
    def without_layers( *layer_symbols, &block )
      layers = layer_symbols.collect do | layer_symbol |
        ContextR.layer_by_name( ContextR.layerize( layer_symbol ) )
      end
      Dynamic.let( { :layers => Dynamic[:layers] - layers }, &block )
    end
    alias without_layer without_layers

    # allows the explicit deactivation of layers
    # 
    #   ContextR::activate_layers( :foo, :bar )
    #   ContextR::current_layers            # => [:default, :foo, :bar]
    #
    #   ContextR::deactivate_layers( :foo )
    #   ContextR::current_layers            # => [:default, :bar]
    #
    # :call-seq:
    #   deactivate_layers( layer_name, ... )
    #
    def deactivate_layers( *layer_symbols )
      layers = layer_symbols.collect do | layer_symbol |
        ContextR.layer_by_name( ContextR.layerize( layer_symbol ) )
      end
      Dynamic[:layers] -= layers
    end
    alias deactivate_layer deactivate_layers

    # returns the names of the currently activated layers
    #
    #   ContextR::current_layers              # => [:default]
    #
    #   ContextR::with_layers :foo do
    #     ContextR::current_layers            # => [:default, :foo]
    #   end
    def current_layers
      Dynamic[:layers].collect{ | layer_class | self.symbolize( layer_class ) }
    end

    # allows the registration of context sensors. These are blocks that are
    # called on with_current_context and should return a list of layers, that
    # should be activated.
    # 
    #   ContextR::add_context_sensor do
    #     # some clever code computes some layers to activate
    #     [ :foo ]
    #   end
    #
    # :call-seq:
    #   add_context_sensor() { ... }
    #
    def add_context_sensor &block
      @sensors ||= []
      @sensors << block
    end

    # asks all sensors to compute the current context, e.g. layers that should
    # be active, and executes the given block in the context. It works basically
    # like with_layers
    # 
    # :call-seq:
    #   with_current_context() { ... }
    #
    def with_current_context(&block) 
      layers = @sensors.inject([]) do | akku, sensor |
        akku | sensor.call
      end
      ContextR::with_layers(*layers) do
        block.call
      end
    end

    def symbolize( layer_klass ) # :nodoc:
      layer_klass.namespace_free_name.gsub( "Layer", "" ).downcase.to_sym
    end

    def layerize( layer_symbol ) # :nodoc:
      "#{layer_symbol}_layer".camelize
    end
    
    def layer_by_symbol( layer_symbol ) # :nodoc:
      layer_by_name( layerize( layer_symbol ) )
    end

    def layer_by_name( layer_name ) # :nodoc:
      unless ContextR.const_defined?( layer_name )
        ContextR::module_eval( 
            "class #{layer_name} < Layer; end", __FILE__, __LINE__ )
        # ContextR.const_set( layer_name, Class.new( ContextR::Layer ) )
      end
      ContextR.const_get( layer_name )
    end

    def current_layer # :nodoc:
      Layer.compose( Dynamic[:layers] )
    end

  end

  extend ClassMethods
end
