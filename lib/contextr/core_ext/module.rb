class Module 
  alias_method :extend_without_layers, :extend
  def extend_with_layers(associations)
    klass = class << self; self; end
    associations.each do | modul, layer |
      ContextR::layer_by_symbol(layer).add_method_collection(klass, modul)
    end
  end
  def extend(*args)
    args.first.is_a?(Module) ? extend_without_layers(*args) : 
                               extend_with_layers(*args)
  end

  alias_method :include_without_layers, :include
  def include_with_layers(associations)
    associations.each do | modul, layer |
      ContextR::layer_by_symbol(layer).add_method_collection(self, modul)
    end
  end

  def include(*args)
    args.first.is_a?(Module) ? include_without_layers(*args) : 
                               include_with_layers(*args)
  end
end
