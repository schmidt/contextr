module ContextR
  class InnerClass # :nodoc:
    #--
    # Copyright 2004, 2006 by Jim Weirich (jim@weirichhouse.org).
    # All rights reserved.

    # Permission is granted for use, copying, modification, distribution,
    # and distribution of modified versions of this work as long as the
    # above copyright notice is included.
    #++
    class << self
      # Hide the method named +name+ in the BlankSlate class.  Don't
      # hide +instance_eval+ or any method beginning with "__".
      def hide(name)
        if instance_methods.include?(name.to_s) and
          name !~ /^(__|instance_eval)/
          @hidden_methods ||= {}
          @hidden_methods[name.to_sym] = instance_method(name)
          undef_method name
        end
      end

      def find_hidden_method(name)
        @hidden_methods ||= {}
        @hidden_methods[name] || superclass.find_hidden_method(name)
      end

      # Redefine a previously hidden method so that it may be called on a blank
      # slate object.
      def reveal(name)
        bound_method = nil
        unbound_method = find_hidden_method(name)
        fail "Don't know how to reveal method '#{name}'" unless unbound_method
        define_method(name) do |*args|
          bound_method ||= unbound_method.bind(self)
          bound_method.call(*args)
        end
      end
    end
    
    instance_methods.each { |m| hide(m) }

    def method_missing(method_name, *rest_args)
      if block_given?
        yield(:next, *rest_args)
      else
        super
      end
    end
  end
end
