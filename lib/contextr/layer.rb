module ContextR
  # This is the public interface of a Layer within a class definition. Use it
  # to add context-dependent behaviour. It is available after calling 
  # +layer <em>layer_name</em>+ within a class body via 
  # +<em>layer_name</em>+. Each wrapper block should expect an instance of
  # MethodNature to manipulate arguments or return values.
  #
  #  class Foo
  #    layer :any
  #
  #    def bar
  #      "bar"
  #    end
  #
  #    any.before :bar do | n |
  #      logger.info "Foo#bar called"
  #    end
  #  end
  class LayerInClass
    attr_accessor :contextualized_class, :layer # :nodoc:

    def initialize(contextualized_class, layer) # :nodoc:
      self.contextualized_class = contextualized_class 
      self.layer = layer
    end

    # Adds a before-wrapper to a single method.
    #
    # :call-seq:
    #   before(method_name) { | method_nature | ... }
    #
    def before(method_name, &block)
      layer.methods_of(self.contextualized_class)[method_name].befores << 
          block.to_unbound_method(self.contextualized_class)
      nil
    end

    # Adds a after-wrapper to a single method
    #
    # :call-seq:
    #   after(method_name) { | method_nature | ... }
    #
    def after(method_name, &block)
      layer.methods_of(self.contextualized_class)[method_name].afters <<
          block.to_unbound_method(self.contextualized_class)
      nil
    end

    # Adds an around-wrapper to a single method
    #
    # :call-seq:
    #   around(method_name) { | method_nature | ... }
    #
    def around(method_name, &block)
      layer.methods_of(self.contextualized_class)[method_name].arounds << 
          block.to_unbound_method(self.contextualized_class)
      nil
    end

    # restrict a method to a single layer. Calling it will raise a
    # NoMethodError, if the given layer is inactive.
    def use(method_name)
      self.contextualized_class.class_eval(%Q{
        alias_method(:#{self.layer.to_sym}_saved_#{method_name}, 
                     :#{method_name})
        private :#{self.layer.to_sym}_saved_#{method_name}
        def #{method_name}(*arguments)
          if #{self.layer.name}.active?
            #{self.layer.to_sym}_saved_#{method_name}(*arguments)
          else
            super
          end
        end
      }, __FILE__, __LINE__)
    end
  end

  class Layer # :nodoc:
    # its role as base instance of all layers
    class << self
      attr_accessor_with_default_setter :base_layers, :combined_layers do 
        Hash.new
      end

      def core_methods
        @core_methods ||= Hash.new do | hash, extended_class |
          add_redefine_callback(extended_class)
          hash[extended_class] = Hash.new do | class_hash, method_name |
            um = extended_class.instance_method(method_name)
            replace_core_method(extended_class, method_name)
            class_hash[method_name] = um 
          end
        end
      end

      def inherited(new_base_layer)
        unless new_base_layer.name.nil? or new_base_layer.name.empty?
          base_layers[ContextR::symbolize(new_base_layer)] = new_base_layer
        end
      end

      def compose(layers)
        # TODO: Add better caching
        combined_layers[ layers ] ||= 
          layers.reverse.inject(nil) do | akku, layer |
            layer + akku
          end
      end

    protected
      def replace_core_method(extended_class, method_name)
        num_of_args = extended_class.instance_method(method_name).arity
        arg_signature = case num_of_args <=> 0
        when 0
          ""
        when 1
          "%s" % Array.new(num_of_args) { |i| "arg%d" % i }.join(", ")
        else 
          "*arguments"
        end
        arg_call = arg_signature.empty? ? "" : ", " + arg_signature

        extended_class.class_eval(%Q{
          remove_method :#{method_name}
          def #{method_name} #{arg_signature} 
            ContextR::current_layer.extended(self).send(
                :#{method_name}#{arg_call})
          end
        }, __FILE__, __LINE__)
      end

      def add_redefine_callback(extended_class)
        (class << extended_class; self; end).instance_eval do
          define_method(:method_added) do | method_name |
            if ContextR::Layer.core_methods[extended_class].
                  include?(method_name)
              warn(caller.first + " : ContextR - Redefining already wrapped methods is not supported yet. Your changes _may_ have no effect.")
            end
          end
        end
      end
    end
  end

  class Layer # :nodoc:
    # its role as base class for all other layers
    class << self
      attr_accessor_with_default_setter :extended_classes do 
        Hash.new do | classes, extended_class |
          classes[extended_class] = Hash.new do | hash, key |
              hash[key.to_sym] = ContextualizedMethod.new(
                  ContextR::Layer.core_methods[ extended_class ][ key.to_sym ])
            end
          end
      end
      attr_accessor :extended_objects

      def methods_of(extended_class)
        self.extended_classes[extended_class]
      end

      def extended(object)
        self.extended_objects ||= SimpleWeakHash.new
        ret = self.extended_objects[object]
        if ret.nil? 
          object_class = if object.kind_of? Class
            (class << object; self; end)
          else
            object.class
          end
          ret = ExtendedObject.new(object, self.methods_of(object_class))
          self.extended_objects[ object ] = ret 
        end
        ret
      end

      def + other_layer
        if other_layer.nil?
          self
        else
          combined_layer = Class.new(Layer)
          combined_layer.extended_classes = self.merge_extended_classes_with(
                other_layer.extended_classes)
          combined_layer
        end
      end

      def to_sym
        ContextR::symbolize(self)
      end

      def active?
        ContextR::current_layers.include? self.to_sym
      end

      def in(klass)
        @layer_in_classes ||= {}
        @layer_in_classes[klass] ||= ContextR::LayerInClass.new(klass, self)
      end

    protected

      def merge_extended_classes_with(other_ec)
        extended_classes.merge(other_ec) do | extended_c, my_ms, other_ms | 
          my_ms.merge(other_ms) do | method_name, my_cm, other_cm |
            my_cm + other_cm
          end
        end
      end
    end
  end

  class ExtendedObject # :nodoc:
    attr_accessor :proxied_object
    attr_accessor :extended_methods
    attr_accessor :behaviours

    def initialize(proxied_object, extended_methods)
      self.proxied_object = proxied_object
      self.extended_methods = extended_methods
      self.behaviours = {}
    end

    def send(method_name, *arguments)
      (self.behaviours[method_name] ||=
          self.extended_methods[method_name].behaviour(self.proxied_object) 
     ).call(*arguments)
    end
  end

  class ContextualizedMethod # :nodoc:
    attr_accessor :core
    attr_accessor :behaviour_cache

    attr_accessor_with_default_setter :befores, :afters, :arounds do 
      Array.new
    end
    
    def initialize(unbound_core_method)
      self.core = unbound_core_method
      self.behaviour_cache = {} 
    end

    def + other_cm
      new_cm = ContextualizedMethod.new(self.core)
      new_cm.befores = self.befores + other_cm.befores
      new_cm.afters  = self.afters  + other_cm.afters
      new_cm.arounds = self.arounds + other_cm.arounds
      new_cm
    end

    def behaviour(instance)
      self.behaviour_cache[instance] ||= 
          self.send(self.behaviour_name, instance)
    end

    def behaviour_name
      wrappers = []
      wrappers << "befores" unless self.befores.empty?
      wrappers << "arounds" unless self.arounds.empty?
      wrappers << "afters" unless self.afters.empty?

      "behaviour_" + (wrappers.empty? ? "without_wrappers" : 
                                         "with_" + wrappers.join("_and_"))
    end

    def behaviour_without_wrappers(instance)
      self.core.bind(instance)
    end

    def behaviour_with_befores(instance)
      combined_befores = self.combine_befores(instance)
      bound_core = self.bind_core(instance)

      lambda do | *arguments |
        nature = MethodNature.new(arguments, nil, false)

        combined_befores.call(nature)
        unless nature.break
          bound_core.call(*nature.arguments)
        else
          nature.return_value
        end
      end
    end

    def behaviour_with_afters(instance)
      bound_core = self.bind_core(instance)
      combined_afters = self.combine_afters(instance)

      lambda do | *arguments |
        nature = MethodNature.new(arguments, nil, false)

        nature.return_value = bound_core.call(*arguments)
        combined_afters.call(nature)

        nature.return_value
      end
    end

    def behaviour_with_befores_and_afters(instance)
      combined_befores = self.combine_befores(instance)
      bound_core = self.bind_core(instance)
      combined_afters = self.combine_afters(instance)

      lambda do | *arguments |
        nature = MethodNature.new(arguments, nil, false)

        combined_befores.call(nature)
        unless nature.break
          nature.return_value = bound_core.call(*nature.arguments)
          combined_afters.call(nature)
        end
        nature.return_value
      end
    end

    def behaviour_with_arounds(instance)
      bound_core = self.bind_core(instance)
      bound_arounds = self.bind_arounds(instance)

      lambda do | *arguments |
        working_arounds = bound_arounds.clone
        nature = MethodNature.new(arguments, nil, false)
        nature.block = around_block(nature, working_arounds, bound_core)

        catch(:break_in_around) do
          working_arounds.shift.call(nature)
        end
        nature.return_value
      end
    end

    def behaviour_with_befores_and_arounds(instance)
      combined_befores = self.combine_befores(instance)
      bound_core = self.bind_core(instance)
      bound_arounds = self.bind_arounds(instance)

      lambda do | *arguments |
        nature = MethodNature.new(arguments, nil, false) 

        combined_befores.call(nature)
        unless nature.break
          working_arounds = bound_arounds.clone
          nature.block = around_block(nature, working_arounds, bound_core)
          catch(:break_in_around) do
            working_arounds.shift.call(nature)
          end
        end
        nature.return_value
      end
    end

    def behaviour_with_arounds_and_afters(instance)
      bound_core = self.bind_core(instance)
      bound_arounds = self.bind_arounds(instance)
      combined_afters = self.combine_afters(instance)

      lambda do | *arguments |
        working_arounds = bound_arounds.clone
        nature = MethodNature.new(arguments, nil, false,
                      around_block(nature, working_arounds, bound_core)) 

        catch(:break_in_around) do
          working_arounds.shift.call(nature)
        end
        combinded_afters.call(nature) unless nature.break

        nature.return_value
      end
    end

    def behaviour_with_befores_and_arounds_and_afters(instance)
      combined_befores = self.combine_befores(instance)
      bound_core = self.bind_core(instance)
      bound_arounds = self.bind_arounds(instance)
      combined_afters = self.combine_afters(instance)

      lambda do | *arguments |
        nature = MethodNature.new(arguments, nil, false) 

        combined_befores.call(nature)
        unless nature.break
          working_arounds = bound_arounds.clone
          nature.block = around_block(nature, working_arounds, bound_core)
          catch(:break_in_around) do
            working_arounds.shift.call(nature)
          end
          unless nature.break
            combined_afters.call(nature)
          end
        end
        nature.return_value
      end
    end


    # helpers
    def combine_befores(instance)
      bound_befores = self.befores.collect { | p | p.bind(instance) }
      lambda do | nature |
        bound_befores.each do | bound_before |
          bound_before.call(nature)
          break if nature.break
        end
      end
    end

    def bind_arounds(instance)
      self.arounds.collect { | a | a.bind(instance) }
    end

    def around_block(nature, bound_arounds, bound_core)
      lambda do
        unless bound_arounds.empty?
          bound_arounds.shift.call(nature)
          throw(:break_in_around) if nature.break
        else
          nature.return_value = bound_core.call(*nature.arguments)
        end
      end
    end

    def bind_core(instance)
      self.core.bind(instance)
    end

    def combine_afters(instance)
      bound_afters = self.afters.collect { | p | p.bind(instance) }
      lambda do | nature |
        bound_afters.reverse.each do | bound_after |
          bound_after.call(nature)
          break if nature.break
        end
        nature.return_value
      end
    end
  end
end

