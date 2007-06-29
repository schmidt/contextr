module ContextR
  class Layer
    module ClassMethods
      def definitions
        @definitions ||= {}
      end
      def proxies
        @proxies ||= {}
      end

      def add_method_collection(contextified_class, methods_module)
        definitions[contextified_class] = methods_module
        (methods_module.instance_methods & 
         contextified_class.instance_methods).each do | method_name |
          replace_core_method(contextified_class, method_name, 0)
        end
        register_callbacks(contextified_class, methods_module)
      end

      def context_proxy(contextified_class, method_name)
        if definitions[contextified_class] and 
           definitions[contextified_class].instance_methods.include?(
                                                            method_name.to_s)
          proxies[contextified_class] ||= begin
            c = Class.new 
            c.class_eval(%Q{
              include ObjectSpace._id2ref(
                    #{definitions[contextified_class].object_id})
            }, __FILE__, __LINE__)
            c.new
          end
        end
      end

      def on_class_method_added(contextified_class, method_name, version)
        if self.definitions[contextified_class].instance_methods.include?(
                                                          method_name.to_s)
          replace_core_method(contextified_class, method_name, version)
        end
      end

      def on_wrapper_method_added(methods_module, method_name, version)
        self.definitions.collect do | each_class, each_methods_module | 
          if (each_methods_module == methods_module) 
            each_class
          end 
        end.compact.each do | contextified_class |
          replace_core_method(contextified_class, method_name, 0)
        end
      end

      def replace_core_method(contextified_class, method_name, version)
        ContextR::observe_core_method(contextified_class, method_name.to_sym,
                                      version)
      end

     def  register_callbacks(cclass, mmodule)
       { :on_wrapper_method_added => mmodule,
         :on_class_method_added   => cclass }.each do | callback, klass |
         ContextR::EventMachine.register(self, callback, 
                                         :on_event => :method_added,
                                         :in_class => klass)
       end
     end
    end
    
    self.extend(ClassMethods)
    
    def self.inherited(klass)
      klass.extend(ClassMethods)
    end
  end
end
