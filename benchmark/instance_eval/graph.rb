require 'rubygems'
require 'gruff'

g = Gruff::Line.new( 480 )
g.title = "Performance of Dynamic Code Invokation" 

g.data("Ruby 1.8.6 (MRI)", [1.0, 2.5, 7.3, 1.2, 2.7])
g.data("Ruby 1.9 (YARV)",  [1.0, 6.3, 48.0, 1.8, 4.3])
g.data("JRuby",            [1.0, 1.6, 26.5, 1.2, 3.1])

g.maximum_value = 30.0
#g.labels = {0 => '2003', 2 => '2004', 4 => '2005'}

g.write(File.dirname(__FILE__) + '/graph.png')
