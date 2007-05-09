class Proc

  # Returns the Proc converted to an UnboundMethod within the the given Class
  #
  #   class A
  #     def a
  #       "a"
  #     end
  #   end
  #
  #   um_a = A.instance_method( :a )   # => #<UnboundMethod: A#a>
  #   um_a.bind( A.new ).call          # => "a"
  #
  #   b = lambda do "b" end
  #   um_b = b.to_unbound_method( A )  # => #<UnboundMethod: A#_um_from_proc>
  #   um_b.bind( A.new ).call          # => "b"
  #
  def to_unbound_method( klass )
    raise ArgumentError.new( "Only class objects allowed in parameter list" 
                                  ) unless klass.kind_of?( Class )

    proc_object = self
    klass.class_eval do
      define_method( :_um_from_proc, &proc_object )
    end

    unbound_method = klass.instance_method( :_um_from_proc )

    klass.class_eval do
      undef_method( :_um_from_proc )
    end

    unbound_method
  end

  # joins to blocks into a new one, that forwards on excution the given 
  # arguments.
  #
  #   a = lambda do print "a" end
  #   b = lambda do print "b" end
  #
  #   ab = a + b
  #
  #   ab.call  # => "ab"
  #
  def +( other_proc )
    this_proc = self
    lambda do | *arguments |
      this_proc.call( *arguments )
      other_proc.call( *arguments )
    end
  end
end
