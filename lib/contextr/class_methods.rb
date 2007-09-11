module ContextR
  module ClassMethods
    include MutexCode

    def const_missing(const_name)
      if const_name.to_s =~ /.*Layer$/
        self.const_set(const_name, Class.new(ContextR::Layer))
      else
        super
      end
    end

    def stored_core_methods
      @stored_core_methods ||= Hash.new do | hash, key |
        hash[key] = Hash.new
      end
    end

    def active_layers_as_classes
      Dynamic[:layers]
    end

    def layered_do(layers, block)
      Dynamic.let({:layers => layers}, &block)
    end

    def layers_as_classes
      constants.select { |l| l =~ /.+Layer$/ }.collect { |l| 
        l.scan(/(.+)Layer/).first.first.underscore.to_sym
      }
    end

    def symbol_by_layer(lay)
      lay.to_s.gsub( /^ContextR::(.*)Layer$/, '\1' ).underscore.to_sym
    end

    def layer_by_symbol(sym)
      "ContextR::#{sym.to_s.camelize}Layer".constantize
    end

    def call_methods_stack(stack, receiver, method_name, arguments, block)
      if stack.size == 1
        stack.pop.call(*arguments, &block)
      else
        stack.pop.send(method_name, *arguments) do | action, *rest_args |
          case action
          when :receiver
            receiver
          when :block
            block.call(*rest_args)
          when :next
            call_methods_stack(stack, receiver, method_name, rest_args, block)
          else 
            raise ArgumentError.new("Use only :receiver, :block or :next " +
                                    "as first argument.")
          end
        end
      end
    end

    def on_core_method_called(receiver, contextified_class, 
                              method_name, arguments, block)
      proxies = []
      active_layers_as_classes.each do |layer|
        proxies += layer.context_proxies(contextified_class, method_name)
      end.compact 

      proxies << core_proxy(receiver, contextified_class, method_name) 
      call_methods_stack(proxies.reverse, receiver, 
                         method_name, arguments, block)
    end

    def core_proxy(receiver, contextified_class, method_name)
      ContextR::stored_core_methods[contextified_class][
        method_name][:code].bind(receiver)
    end

    def observe_core_method(klass, method_name, version)
      only_once do
        klass.class_eval(%Q{
            def #{method_name}(*arguments, &block)
              ContextR::on_core_method_called(
                self,
                ObjectSpace._id2ref(#{klass.object_id}), 
                :#{method_name},
                arguments, block)
            end
          }, __FILE__, __LINE__) if save_core_method(klass, method_name, version)
      end
    end

    def save_core_method(klass, method_name, version)
      if !meta_method?(method_name) and 
          (!stored_core_methods[klass].include?(method_name) or
              stored_core_methods[klass][method_name][:version] < version)
        stored_core_methods[klass][method_name] = 
          { :version => version, :code => klass.instance_method(method_name) }
      end
    end

    def meta_method?(method_name)
      method_name.to_s =~ /method_added(_with(out)?_contextr_listener)?/
    end
  end
  self.extend(ClassMethods)
end
