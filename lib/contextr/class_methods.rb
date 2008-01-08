module ContextR # :nodoc:
  module ClassMethods # :nodoc:
    include MutexCode

    def stored_core_methods
      @stored_core_methods ||= Hash.new do |hash, key|
        hash[key] = Hash.new
      end
    end

    def stored_module_definitions
      @stored_module_definitions ||= Hash.new do |hash, key|
        hash[key] = Hash.new do |hash, key|
          hash[key] = Module.new
        end
      end
    end

    def active_layers_as_classes
      Dynamic[:layers]
    end

    def layered_do(layers, block)
      Dynamic.let({:layers => layers}, &block)
    end

    def layers_as_classes
      @layers.values
    end

    def symbol_by_layer(lay)
      @layers.index(lay)
    end

    def layer_by_symbol(sym)
      @layers[sym] ||= ContextR::Layer.new
    end

    def call_methods_stack(stack, receiver, method_name, arguments, block)
      if stack.size == 1
        stack.pop.call(*arguments, &block)
      else
        stack.pop.__send__(method_name, *arguments) do |action, *rest_args|
          case action
          when :receiver
            receiver
          when :block
            block
          when :block=
            block = rest_args.first
          when :block_given?
            !block.nil?
          when :next
            rest_args.shift if method_name != :method_missing
            call_methods_stack(stack, receiver, method_name, rest_args, block)
          else 
            raise ArgumentError, "Use only :receiver, :block, :block_given?, " +
                                 ":block= or :next as first argument."
          end
        end
      end
    end

    def on_core_method_called(receiver, contextified_class, 
                              method_name, arguments, block)
      proxies = []
      active_layers_as_classes.each do |layer|
        proxies += layer.context_proxies(receiver, 
                                         contextified_class, 
                                         method_name)
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
            if self.instance_methods.include?("#{method_name}")
              undef_method("#{method_name}")
            end
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

    def self.extended(base)
      base.instance_variable_set(:@layers, {})
    end
  end
  self.extend(ClassMethods)
end
