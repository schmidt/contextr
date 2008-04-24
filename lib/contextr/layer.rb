module ContextR # :nodoc:
  class Layer
    def activated
      nil
    end
    def deactivated
      nil
    end
    def inspect
      "ContextR::layer(:#{ContextR::symbol_by_layer(self)})"
    end
    alias_method :to_s, :inspect

  # :nodoc: all
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

    def methods_module_containing_method(contextified_class, method_name)
      if definitions.include?(contextified_class) and
         definitions[contextified_class].instance_methods.include?(method_name.to_s) 
        definitions[contextified_class]
      end
    end

    def context_proxy(contextified_class, method_name)
      methods_module = methods_module_containing_method(contextified_class, 
                                                        method_name)

      if methods_module 
        proxies[methods_module] ||= begin
          p = ContextR::InnerClass.new
          class << p; self; end.class_eval do
            include(methods_module)
          end
          p
        end
      end
    end

    def on_class_method_added(contextified_class, method_name, version)
      if methods_module_containing_method(contextified_class, method_name)
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

    def register_callbacks(cclass, mmodule)
      {:on_wrapper_method_added => mmodule,
       :on_class_method_added   => cclass }.each do | callback, klass |
       ContextR::EventMachine.register(self, callback, 
                                       :on_event => :method_added,
                                       :in_class => klass)
      end
    end
  end
end
