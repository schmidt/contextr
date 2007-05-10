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
