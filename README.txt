= ContextR

A context-oriented programming library for Ruby. 

Inspired by ContextL (Pascal Costanza) and ContextS (Robert Hirschfeld) with 
thanks to Christian Neukirchen for giving the name and lots of ideas.

For more information see 
- http://www.contextr.org/ or 
- http://www.swa.hpi.uni-potsdam.de/cop/

This code is published under the same license as Ruby. See LICENSE for more 
information.

(c) 2007 - Gregor Schmidt - Berlin, Germany

= Usage

  require 'rubygems'
  require 'contextr'

  class A
    def a
      puts "a"
    end
 
    layer :foo

    foo.post :a do | n |
      n.return_value += "_with_context"
    end
  end

  A.new.a      # => "a"

  ContextR::with_layers( :foo ) do
    A.new.a    # => "a_with_context"
  end

= Starting Points

For a more detailed description
- visit the project homepage at RubyForge[http://contextr.rubyforge.org/]
- have a look at the examples folder in the ContextR distribution

For detailed API descriptions have a look at the following classes and modules
- Class
- ContextR::LayerInClass 
- ContextR::ClassMethods
