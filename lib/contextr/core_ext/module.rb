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

  # Marks a module as layer specific behaviour of the surrounding class
  #    
  #    class Klass
  #      def name
  #        "Klass"
  #      end
  #
  #      module Mod
  #        in_layer :hello
  #        def name
  #          "Hello from #{yield(:next)}.\n"
  #        end
  #      end
  #    end
  #    
  #    k = Klass.new
  #    k.name                    #=> "Klass.\n"
  #    ContextR::with_layer :hello do
  #      k.name                  #=> "Hello from Klass.\n"
  #    end
  #    k.name                    #=> "Klass.\n"
  #
  #  This does not work in anonymous classes. The module is always attached to
  #  the innermost surrounding class or module.
  def in_layer(layer_symbol)
    parts = self.name.split("::")
    
    raise ArgumentError.new("May not use in_layer with anonymous " +
                            "classes or modules") if parts.size < 2

    modules = (1..parts.size - 1).map {|i| parts[0...i].join("::").constantize}
    surrounding = modules.reverse.find {|klass| klass.is_a? Module}
    
    raise ArgumentError.new("in_layer used in module without surrounding " + 
                            "class or module") if surrounding.nil? 

    ContextR::layer_by_symbol(layer_symbol).add_method_collection(surrounding, 
                                                                  self)
  end
end

Module.class_eval do
  private :include
  private :include_with_layers
end
