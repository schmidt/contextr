#--
# TODO: get rid of this workaround to avoid double loading on `rake test`
#++
unless Object.const_defined? "ContextR"
#  if RUBY_VERSION == "1.9.0"
#    require File.dirname(__FILE__) + '/activesupport/lib/active_support'
#  else
    require 'rubygems'
    require 'active_support'
#  end

  Dir[File.join(File.dirname(__FILE__), 'ext/**/*.rb')].sort.each { |lib| require lib }
  Dir[File.join(File.dirname(__FILE__), 'core_ext/**/*.rb')].sort.each { |lib| require lib }
  Dir[File.join(File.dirname(__FILE__), 'contextr/**/*.rb')].sort.each { |lib| require lib }

end
unless Dynamic.variables.include?( :layers )
  Dynamic.variable( :layers => [ ContextR::layer_by_symbol( :default ) ] )
end
