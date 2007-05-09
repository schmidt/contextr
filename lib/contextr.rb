#--
# TODO: get rid of this workaround to avoid double loading on `rake test`
#++
unless Object.const_defined? "ContextR"
  require 'rubygems'
  require 'active_support'

  Dir[File.join(File.dirname(__FILE__), '../ext/**/*.rb')].sort.each { |lib| require lib }
  Dir[File.join(File.dirname(__FILE__), 'core_ext/**/*.rb')].sort.each { |lib| require lib }
  Dir[File.join(File.dirname(__FILE__), 'contextr/**/*.rb')].sort.each { |lib| require lib }

end
unless Dynamic.variables.include?( :layers )
  Dynamic.variable( :layers => [ ContextR::DefaultLayer ] )
end
