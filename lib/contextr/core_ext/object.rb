class Object #:nodoc:
  def behavioural_class #:nodoc:
    if self.kind_of?(Module)
      class << self; self; end
    else
      self.class
    end
  end
end
