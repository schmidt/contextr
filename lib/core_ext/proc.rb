class Proc
  def to_unbound_method( klass )
    raise ArgumentError.new( "Only class objects allowed in parameter list" 
                                  ) unless klass.kind_of?( Class )

    proc_object = self
    klass.class_eval do
      define_method( :_tmp_method_from_proc, &proc_object )
    end

    unbound_method = klass.instance_method( :_tmp_method_from_proc )

    klass.class_eval do
      undef_method( :_tmp_method_from_proc )
    end

    unbound_method
  end

  def +( other_proc )
    this_proc = self
    lambda do | *arguments |
      this_proc.call( *arguments )
      other_proc.call( *arguments )
    end
  end
end
