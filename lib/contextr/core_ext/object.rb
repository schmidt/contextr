#--
# The aliasing of these methods is done in a class_eval block to avoid code
# documentation by RDoc.
#++
Object.class_eval do
  alias_method :extend_without_layers, :extend   
end

class Object
  def extend_with_layers(associations) # :nodoc:
    klass = class << self; self; end
    associations.each do | modul, layer |
      ContextR::layer_by_symbol(layer).add_method_collection(klass, modul)
    end
    self
  end

  # call-seq:
  #    obj.extend(module, ...)    => obj
  #    obj.extend(module => layer_qualifier, ...)    => obj
  # 
  # Adds to _obj_ the instance methods from each module given as a
  # parameter.
  #    
  #    module Mod
  #      def hello
  #        "Hello from Mod.\n"
  #      end
  #    end
  #    
  #    class Klass
  #      def hello
  #        "Hello from Klass.\n"
  #      end
  #    end
  #    
  #    k = Klass.new
  #    k.hello         #=> "Hello from Klass.\n"
  #    k.extend(Mod)   #=> #<Klass:0x401b3bc8>
  #    k.hello         #=> "Hello from Mod.\n"
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
  #    end
  #    
  #    k = Klass.new
  #    k.extend(Mod => :hello)   #=> #<Klass:0x401b3bc8>
  #    k.name                    #=> "Klass.\n"
  #    ContextR::with_layer :hello do
  #      k.name                  #=> "Hello from Klass.\n"
  #    end
  #    k.name                    #=> "Klass.\n"
  def extend(*args)
    args.first.is_a?(Module) ? extend_without_layers(*args) : 
                               extend_with_layers(*args)
  end

  def behavioural_class #:nodoc:
    if self.kind_of?(Module)
      class << self; self; end
    else
      self.class
    end
  end
end
