require 'rubygems'
require 'active_support'

require File.dirname(__FILE__) + '/ext/dynamic'
require File.dirname(__FILE__) + '/ext/method_nature'

require File.dirname(__FILE__) + '/lib/core_ext/class'
require File.dirname(__FILE__) + '/lib/core_ext/module'
require File.dirname(__FILE__) + '/lib/core_ext/proc'

require File.dirname(__FILE__) + '/lib/contextr'

if not Dynamic.variables.include?( :layers )
  Dynamic.variable( :layers => [ ContextR::DefaultLayer ] )
end
