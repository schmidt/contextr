class Module
  # returns the name without namespace prefixes
  #
  #   module A
  #     module B
  #       module C
  #       end
  #     end
  #   end
  #   module C
  #   end
  #
  #   A::B::C.name  # => "A::B::C"
  #   C.name        # => "C"
  #   A::B::C.namespace_free_name # => "C"
  #   C.namespace_free_name       # => "C"
  #
  def namespace_free_name
    self.name.match( /(\w*?)$/ )[1]
  end

  # allows the definition of an attr_accessor with a setter, that is used
  # to set the instance variable if it is accessed before set.
  #
  #   class A
  #     attr_accessor_with_default_setter :first_access { Time.now }
  #   end
  #  
  #   A.new.first_access # => Wed May 09 18:23:36 0200 2007
  #
  #   a1 = A.new
  #   a1.first_access    # => Wed May 09 18:23:38 0200 2007
  #   a1.first_access    # => Wed May 09 18:23:38 0200 2007
  #
  #   a2 = A.new
  #   a2.first_access = Time.now - 10.days
  #   a2.first_access    # => Sun Apr 29 18:23:40 0200 2007
  #
  # :call-seq:
  #   attr_accessor_with_default_setter(symbol, ...) { ... }
  #
  def attr_accessor_with_default_setter( *syms ) 
    raise 'Default value in block required' unless block_given?
    syms.each do | sym |
      module_eval do
        attr_writer( sym )
        define_method( sym ) do | |
          class << self; self; end.class_eval do 
            attr_reader( sym )
          end

          if instance_variables.include? "@#{sym}"
            instance_variable_get( "@#{sym}" )
          else
            instance_variable_set( "@#{sym}", yield )
          end
        end
      end
    end
    nil
  end
end
