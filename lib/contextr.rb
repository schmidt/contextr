module ContextR
  @@genid = 0
  class << self
    def gensym( name, kind = "", postfix = "_%05d_" )
      @@genid += 1
      ( "_#{name}_#{kind}#{postfix}" % @@genid ).intern
    end

    def symbolize( layer_klass )
      layer_klass.namespace_free_name.gsub( "Layer", "" ).downcase.to_sym
    end

    def layerize( layer_symbol )
      "#{layer_symbol}_layer".camelize
    end

    def with_layers( *layer_symbols, &block )
      layers = layer_symbols.collect do | layer_symbol |
        ContextR.layer_by_name( ContextR.layerize( layer_symbol ) )
      end
      Dynamic.let( { :layers => Dynamic[:layers] | layers }, &block )
    end

    def without_layers( *layer_symbols, &block )
      layers = layer_symbols.collect do | layer_symbol |
        ContextR.layer_by_name( ContextR.layerize( layer_symbol ) )
      end
      Dynamic.let( { :layers => Dynamic[:layers] - layers }, &block )
    end

    def layer_by_symbol( layer_symbol )
      layer_by_name( layerize( layer_symbol ) )
    end

    def layer_by_name( layer_name )
      unless ContextR.const_defined?( layer_name )
        # TODO: Replace with code, that does not need string eval
        ContextR::module_eval( 
            "class #{layer_name} < Layer; end", __FILE__, __LINE__ )
        # ContextR.const_set( layer_name, Class.new( ContextR::Layer ) )
      end
      ContextR.const_get( layer_name )
    end

    def current_layer
      Layer.compose( Dynamic[:layers] )
    end
  end


  class Layer # its role as base instance of all layers
    class << self
      attr_accessor_with_default_setter :base_layers, :combined_layers do 
        Hash.new
      end

      def core_methods
        @core_methods ||= Hash.new do | hash, extended_class |
          add_redefine_callback( extended_class )
          hash[extended_class] = Hash.new do | class_hash, method_name |
            um = extended_class.instance_method( method_name )
            replace_core_method( extended_class, method_name )
            class_hash[method_name] = um 
          end
        end
      end

      def inherited( new_base_layer )
        unless new_base_layer.name.empty?
          base_layers[ContextR::symbolize( new_base_layer )] = new_base_layer
        end
      end

      def compose( layers )
        # TODO: Add better caching
        combined_layers[ layers ] ||= 
          layers.reverse.inject( nil ) do | akku, layer |
            layer + akku
          end
      end

    protected
      def replace_core_method( extended_class, method_name )
        num_of_args = extended_class.instance_method( method_name ).arity
        arg_signature = case num_of_args <=> 0
        when 0
          ""
        when 1
          "%s" % Array.new( num_of_args ) { |i| "arg%d" % i }.join( ", " )
        else 
          "*arguments"
        end
        arg_call = arg_signature.empty? ? "" : ", " + arg_signature

        extended_class.class_eval %Q{
          def #{method_name} #{arg_signature} 
            ContextR::current_layer.extended( self ).send(
                :#{method_name}#{arg_call} )
          end
        }
      end

      def add_redefine_callback( extended_class )
        (class << extended_class; self; end).instance_eval do
          define_method( :method_added ) do | method_name |
            if ContextR::Layer.core_methods[extended_class].
                  include?( method_name )
              warn( caller.first + " : ContextR - Redefining already wrapped methods is not supported yet. Your changes _may_ have no effect." )
            end
          end
        end
      end
    end
  end

  class Layer # its role as base class for all other layers
    class << self
      attr_accessor_with_default_setter :extended_classes do 
        Hash.new do | classes, extended_class |
          classes[extended_class] = Hash.new do | hash, key |
              hash[key] = ContextualizedMethod.new( 
                      ContextR::Layer.core_methods[ extended_class ][ key ] )
            end
          end
      end
      attr_accessor :extended_objects

      def methods_of( extended_class )
        self.extended_classes[extended_class]
      end

      def extended( object )
        self.extended_objects ||= Hash.new do | cache, object |
          cache[ object ] = 
              ExtendedObject.new( object, self.methods_of( object.class ) )
        end
        self.extended_objects[object]
      end

      def + other_layer
        if other_layer.nil?
          self
        else
          combined_layer = Class.new( Layer )
          combined_layer.extended_classes = self.merge_extended_classes_with( 
                other_layer.extended_classes )
          combined_layer
        end
      end

    protected

      def merge_extended_classes_with( other_ec )
        extended_classes.merge( other_ec ) do | extended_c, my_ms, other_ms | 
          my_ms.merge( other_ms ) do | method_name, my_cm, other_cm |
            my_cm + other_cm
          end
        end
      end
    end
  end

  class LayerInClass # its public interface
    attr_accessor :contextualized_class
    attr_accessor :layer

    def initialize( contextualized_class, layer )
      self.contextualized_class = contextualized_class 
      self.layer = layer
    end

    def pre( method_name, &block )
      layer.methods_of( self.contextualized_class )[method_name].pres << 
          block.to_unbound_method( self.contextualized_class )
      nil
    end
    def post( method_name, &block )
      layer.methods_of( self.contextualized_class )[method_name].posts <<
          block.to_unbound_method( self.contextualized_class )
      nil
    end
    def around( method_name, &block )
      layer.methods_of( self.contextualized_class )[method_name].arounds << 
          block.to_unbound_method( self.contextualized_class )
      nil
    end
    alias :wrap :around
  end

  class ExtendedObject
    attr_accessor :proxied_object
    attr_accessor :extended_methods
    attr_accessor :behaviours

    def initialize( proxied_object, extended_methods )
      self.proxied_object = proxied_object
      self.extended_methods = extended_methods
      self.behaviours = {}
    end

    def send( method_name, *arguments )
      ( self.behaviours[method_name] ||=
          self.extended_methods[method_name].behaviour( self.proxied_object ) 
      ).call( *arguments )
    end
  end

  class ContextualizedMethod
    attr_accessor :core
    attr_accessor :behaviour_cache

    attr_accessor_with_default_setter :pres, :posts, :arounds do 
      Array.new
    end
    
    def initialize( unbound_core_method )
      self.core = unbound_core_method
      self.behaviour_cache = {} 
    end

    def + other_cm
      new_cm = ContextualizedMethod.new( self.core )
      new_cm.pres    = self.pres    + other_cm.pres
      new_cm.posts   = self.posts   + other_cm.posts
      new_cm.arounds = self.arounds + other_cm.arounds
      new_cm
    end

    def behaviour( instance )
      self.behaviour_cache[instance] ||= 
          self.send( self.behaviour_name, instance )
    end

    def behaviour_name
      wrappers = []
      wrappers << "pres" unless self.pres.empty?
      wrappers << "arounds" unless self.arounds.empty?
      wrappers << "posts" unless self.posts.empty?

      "behaviour_" + ( wrappers.empty? ? "without_wrappers" : 
                                         "with_" + wrappers.join( "_and_" ) )
    end

    def behaviour_without_wrappers( instance )
      self.core.bind( instance )
    end

    def behaviour_with_pres( instance )
      combined_pres = self.combine_pres( instance )
      bound_core = self.bind_core( instance )
      nature = MethodNature.new

      lambda do | *arguments |
        nature.reset( arguments, nil, false )

        combined_pres.call( nature )
        unless nature.break
          bound_core.call( *nature.arguments )
        else
          nature.return_value
        end
      end
    end

    def behaviour_with_posts( instance )
      bound_core = self.bind_core( instance )
      combined_posts = self.combine_posts( instance )
      nature = MethodNature.new

      lambda do | *arguments |
        nature.reset( arguments, nil, false )

        nature.return_value = bound_core.call( *arguments )
        combined_posts.call( nature )

        nature.return_value
      end
    end

    def behaviour_with_pres_and_posts( instance )
      combined_pres = self.combine_pres( instance )
      bound_core = self.bind_core( instance )
      combined_posts = self.combine_posts( instance )
      nature = MethodNature.new

      lambda do | *arguments |
        nature.reset( arguments, nil, false )

        combined_pres.call( nature )
        unless nature.break
          nature.return_value = bound_core.call( *nature.arguments )
          combined_posts.call( nature )
        end
        nature.return_value
      end
    end

    def behaviour_with_arounds( instance )
      bound_core = self.bind_core( instance )
      bound_arounds = self.bind_arounds( instance )
      nature = MethodNature.new

      lambda do | *arguments |
        working_arounds = bound_arounds.clone
        nature.reset( arguments, nil, false,
                      around_block( nature, working_arounds, bound_core ) ) 

        catch( :break_in_around ) do
          working_arounds.pop.call( nature )
        end
        nature.return_value
      end
    end

    def behaviour_with_pres_and_arounds( instance )
      combined_pres = self.combine_pres( instance )
      bound_core = self.bind_core( instance )
      bound_arounds = self.bind_arounds( instance )
      nature = MethodNature.new

      lambda do | *arguments |
        nature.reset( arguments, nil, false ) 

        combined_pres.call( nature )
        unless nature.break
          working_arounds = bound_arounds.clone
          nature.block = around_block( nature, working_arounds, bound_core )
          catch( :break_in_around ) do
            working_arounds.pop.call( nature )
          end
        end
        nature.return_value
      end
    end

    def behaviour_with_arounds_and_posts( instance )
      bound_core = self.bind_core( instance )
      bound_arounds = self.bind_arounds( instance )
      combined_posts = self.combine_posts( instance )
      nature = MethodNature.new

      lambda do | *arguments |
        working_arounds = bound_arounds.clone
        nature.reset( arguments, nil, false,
                      around_block( nature, working_arounds, bound_core ) ) 

        catch( :break_in_around ) do
          working_arounds.pop.call( nature )
        end
        combinded_posts.call( nature ) unless nature.break

        nature.return_value
      end
    end

    def behaviour_with_pres_and_arounds_and_posts( instance )
      combined_pres = self.combine_pres( instance )
      bound_core = self.bind_core( instance )
      bound_arounds = self.bind_arounds( instance )
      combined_posts = self.combine_posts( instance )
      nature = MethodNature.new

      lambda do | *arguments |
        nature.reset( arguments, nil, false ) 

        combined_pres.call( nature )
        unless nature.break
          working_arounds = bound_arounds.clone
          nature.block = around_block( nature, working_arounds, bound_core )
          catch( :break_in_around ) do
            working_arounds.pop.call( nature )
          end
          unless nature.break
            combined_posts.call( nature )
          end
        end
        nature.return_value
      end
    end


    # helpers
    def combine_pres( instance )
      bound_pres = self.pres.collect { | p | p.bind( instance ) }
      lambda do | nature |
        bound_pres.reverse.each do | bound_pre |
          bound_pre.call( nature )
          break if nature.break
        end
      end
    end

    def bind_arounds( instance )
      self.arounds.collect { | a | a.bind( instance ) }
    end

    def around_block( nature, bound_arounds, bound_core )
      lambda do
        unless bound_arounds.empty?
          bound_arounds.pop.call( nature )
          throw( :break_in_around ) if nature.break
        else
          nature.return_value = bound_core.call( *nature.arguments )
        end
      end
    end

    def bind_core( instance )
      self.core.bind( instance )
    end

    def combine_posts( instance )
      bound_posts = self.posts.collect { | p | p.bind( instance ) }
      lambda do | nature |
        bound_posts.each do | bound_post |
          bound_post.call( nature )
          break if nature.break
        end
      end
    end
  end

  class DefaultLayer < Layer; end
end
