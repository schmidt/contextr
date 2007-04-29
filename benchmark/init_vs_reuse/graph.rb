require 'rubygems'
require 'gruff'

g = Gruff::Line.new( 480 )
g.title = "Initialization vs. Object reuse"

g.data("Ruby 1.8.6 (MRI)",  [ 2.0, 2.15, 1.54 ])
g.data("Ruby 1.9 (YARV)",   [ 2.3, 2.88, 2.02 ])
#g.data("JRuby",            [1.0, 1.6, 26.5, 1.2, 3.1])

g.labels = {0 => 'init', 1 => 'change', 2 => 'reset'}

g.write(File.dirname(__FILE__) + '/graph.png')
