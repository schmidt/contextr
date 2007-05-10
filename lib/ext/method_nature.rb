# This class was created by Christian Neukirchen in the context of 
# EuRuKo 2005 and is licensed under the same terms as Ruby.
#
# It is used within ContextR to provide an interface to manipulate the calling
# context within a method wrapper.
#
# For more information see the corresponding slides at
# http://chneukirchen.org/talks/euruko-2005/chneukirchen-euruko2005-contextr.pdf
#
# (c) 2005 - Christian Neukirchen - http://chneukirchen.org
#
# ---
#
# It provides access
# [+arguments+] to read and manipulate method's arguments.
# [+return_value+] to read and manipulate the method's return value
#
class MethodNature < Struct.new(:arguments, :return_value, :break, :block)

  # stops the execution of the following method wrappers and potentially the 
  # core method.
  #
  #   class A
  #     def a
  #       "a"
  #     end
  #
  #     layer :foo
  #
  #     foo.pre :a do | method_nature |
  #       method_nature.break! "b"
  #     end
  #   end
  #
  #   A.new.a                        # => "a"
  #   ContextR::with_layers :foo do
  #     A.new.a                      # => "b"
  #   end
  #
  # If it is called without parameter, the return value will not be changed.
  #
  # :call-seq:
  #   break!
  #   break!( return_value )
  #
  def break!( *value )
    self.break = true
    self.return_value = value.first unless value.empty?
  end

  # calls the next wrapper with an around method. It corresponds to a super call
  # in an inheritance hierarchy.
  #
  # The example attaches to each method in the class A an around wrapper which 
  # logs access.
  #
  #   class A
  #     def a
  #       "a"
  #     end
  #
  #     layer :log
  #
  #     instance_methods.each do | method |
  #
  #       log.around method.to_sym do | method_nature |
  #         logger.info "before #{self.class}##{method}"
  #
  #         method_nature.call_next
  #
  #         logger.info "after #{self.class}##{method}"
  #       end
  #     end
  #
  #   end
  #
  def call_next
    block.call( *arguments )
  end
end
