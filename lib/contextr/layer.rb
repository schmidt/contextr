module ContextR # :nodoc:
  class Layer # :nodoc: all
    module ClassMethods
      def definitions
        @definitions ||= {}
      end
      def proxies
        @proxies ||= {}
      end

      def add_method_collection(contextified_class, methods_module)
        definitions[contextified_class] ||= []
        definitions[contextified_class].delete(methods_module)
        definitions[contextified_class].push(methods_module)

        (methods_module.instance_methods & 
         contextified_class.instance_methods).each do | method_name |
          replace_core_method(contextified_class, method_name, 0)
        end
        register_callbacks(contextified_class, methods_module)
      end

      def methods_modules_containing_method(contextified_class, method_name)
        if definitions.include?(contextified_class)
          definitions[contextified_class].select do | methods_module | 
            methods_module.instance_methods.include?(method_name.to_s) 
          end
        else
          []
        end
      end

      def context_proxies(receiver, contextified_class, method_name)
        methods_modules_containing_method(contextified_class, method_name).
          collect do | methods_module | 
            context_proxy_for_module(receiver, methods_module) 
          end.reverse
      end

      def context_proxy_for_module(receiver, methods_module)
        proxies[methods_module] ||= SimpleWeakHash.new
        proxies[methods_module][receiver] ||= begin
          c = Class.new(ContextR::InnerClass(receiver)) 
          c.class_eval(%Q{
            include ObjectSpace._id2ref(#{methods_module.object_id})
          }, __FILE__, __LINE__)
          c.new
        end
      end

      def on_class_method_added(contextified_class, method_name, version)
        unless methods_modules_containing_method(contextified_class, 
                                                 method_name).empty?
          replace_core_method(contextified_class, method_name, version)
        end
      end

      def on_wrapper_method_added(methods_module, method_name, version)
        self.definitions.collect do | each_class, each_methods_modules | 
          if each_methods_modules.include?(methods_module)
            each_class
          end 
        end.compact.select do |contextified_class|
          contextified_class.instance_methods.include?(method_name.to_s)
        end.each do | contextified_class |
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
