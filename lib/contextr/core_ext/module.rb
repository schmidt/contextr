#--
# The aliasing of these methods is done in a class_eval block to avoid code
# documentation by RDoc.
#++
Module.class_eval do
  alias_method :extend_without_layers, :extend   
  alias_method :include_without_layers, :include 
end

class Module
  def extend_with_layers(associations) # :nodoc:
    klass = class << self; self; end
    associations.each do | modul, layer |
      ContextR::layer_by_symbol(layer).add_method_collection(klass, modul)
    end
  end

  # TODO document extend
  def extend(*args)
    args.first.is_a?(Module) ? extend_without_layers(*args) : 
                               extend_with_layers(*args)
  end

protected
  def include_with_layers(associations) # :nodoc:
    associations.each do | modul, layer |
      ContextR::layer_by_symbol(layer).add_method_collection(self, modul)
    end
  end

  # TODO document include 
  def include(*args)
    args.first.is_a?(Module) ? include_without_layers(*args) : 
                               include_with_layers(*args)
  end
end
