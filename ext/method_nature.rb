unless Object.const_defined? "MethodNatureSuperClass"
  MethodNatureSuperClass = Struct.new(:arguments, :return_value, :break, :block)
end
class MethodNature < MethodNatureSuperClass 
  def break!( *value )
    self.break = true
    self.return_value = value.first unless value.empty?
  end

  def call_next
    block.call( *arguments )
  end

  def call_next_with( *args )
    block.call( *args )
  end
end
