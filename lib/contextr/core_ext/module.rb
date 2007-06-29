class Module 
  def register(associations)
    if associations.delete(:class_side)
      klass = class << self; self; end
    else
      klass = self
    end
    associations.each do | modul, layer |
      layer.add_method_collection(klass, modul)
    end
  end
end
