require "rubygems"
require "contextr" 

class A
  class << self
    def a
      "a"
    end

    layer :foo

    foo.post :a do | n | 
      n.return_value << " post"
    end
  end
end

ContextR::add_context_sensor do
  [:foo]
end

puts A.a    # => "a"
ContextR::with_layer :foo do
  puts A.a  # => "a post"
end
ContextR::with_current_context do
  puts A.a  # => "a post"
end
puts A.a    # => "a"
