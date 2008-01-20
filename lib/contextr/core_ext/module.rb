class Module
  #  Adds context-dependent behaviour to instances. 
  #
  #    class Klass
  #      def name
  #        "Klass"
  #      end
  #
  #      in_layer :hello do
  #        def name
  #          "Hello from #{super}.\n"
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
  # Note: in_layer automatically generates the inner module
  # and attaches it to the given layer. It is guaranteed, that the inner module
  # used for method definitons will always be the same for any layer x class
  # combination.
  def in_layer(layer_symbol, &block)
    extension = ContextR::stored_module_definitions[layer_symbol][self]

    return_value = extension.module_eval(&block) if block_given?

    ContextR::layer_by_symbol(layer_symbol).add_method_collection(self, 
                                                                  extension) 

    block_given? ? extension : return_value
  end
end
