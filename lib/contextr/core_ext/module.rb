class Module 
  alias_method :include_without_layers, :include
  def include_with_layers(associations)
    if associations.delete(:class_side)
      klass = class << self; self; end
    else
      klass = self
    end
    associations.each do | modul, layer |
      ContextR::layer_by_symbol(layer).add_method_collection(klass, modul)
    end
  end

  def include(*args)
    args.first.is_a?(Module) ? include_without_layers(*args) : 
                               include_with_layers(*args)
  end
end
