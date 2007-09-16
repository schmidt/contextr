#--
# The aliasing of these methods is done in a class_eval block to avoid code
# documentation by RDoc.
#++
Module.class_eval do
  alias_method :include_without_layers, :include 
end

class Module
  protected
  def include_with_layers(associations) # :nodoc:
    associations.each do | modul, layer |
      ContextR::layer_by_symbol(layer).add_method_collection(self, modul)
    end
    self
  end

  # call-seq:
  #    include(module, ...)    => self
  #    include(module => layer_qualifier, ...)    => self
  # 
  # Invokes <code>Module.append_features</code> on each parameter in turn.
  #
  # If called with a hash, adds the module to the given layer. The behaviour 
  # is associated with the class side of the object.
  #
  #    module Mod
  #      def name
  #        "Hello from #{yield(:next)}.\n"
  #      end
  #    end
  #    
  #    class Klass
  #      def name
  #        "Klass"
  #      end
  #
  #      include Mod => :hello
  #    end
  #    
  #    k = Klass.new
  #    k.name                    #=> "Klass.\n"
  #    ContextR::with_layer :hello do
  #      k.name                  #=> "Hello from Klass.\n"
  #    end
  #    k.name                    #=> "Klass.\n"
  #
  def include(*args)
    args.first.is_a?(Module) ? include_without_layers(*args) : 
                               include_with_layers(*args)
  end
end

Module.class_eval do
  private :include
  private :include_with_layers
end
