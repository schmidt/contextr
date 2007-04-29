class Module
  def namespace_free_name
    self.name.match( /(\w*?)$/ )[1]
  end

  def attr_accessor_with_default_setter( *syms, &block )
    raise 'Default value in block required' unless block
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
            instance_variable_set( "@#{sym}", block.call )
          end
        end
      end
    end
    nil
  end
end
