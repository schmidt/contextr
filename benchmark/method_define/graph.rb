require 'rubygems'
require 'gruff'

g = Gruff::Line.new( 480 )
g.title = "Performance of Dynamic Code Invokation" 

g.data( "Ruby 1.8.6 (MRI)", [ 1.00, 1.00, 1.00, 2.80 ] )
g.data( "Ruby 1.9 (YARV)",  [ 1.00, 1.03, 1.03, 1.76 ] )
g.data( "JRuby",            [ 1.00, 1.00, 1.00, 2.60 ])

g.labels = { 0 => 'standard define', 1 => 'standard redefine', 
             2 => 'redefine with string', 3 => 'redefine with block'}

g.write(File.dirname(__FILE__) + '/graph.png')
