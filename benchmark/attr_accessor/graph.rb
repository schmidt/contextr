require 'rubygems'
require 'gruff'

g = Gruff::Line.new( 480 )

g.title = "Different Default Value Implementations" 

g.sort = false
g.data("Initializer",   [2.0, 0.05, 1.3], "#6886B4")
g.data("Custom Getter", [0.7,  0.1, 2.0], "#72AE6E")
g.data("Meta Magic",    [0.7,  2.0, 1.3], "#FDD84E")

g.maximum_value = 2
g.minimum_value = 0 
g.labels = {0 => 'Initialization', 
            1 => 'First access', 
            2 => 'Consequtive Access',  }

g.write(File.dirname(__FILE__) + '/graph.png')
