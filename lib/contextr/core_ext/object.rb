class Object
  def behavioural_class
    if self.kind_of?(Module)
      class << self; self; end
    else
      self.class
    end
  end
end
