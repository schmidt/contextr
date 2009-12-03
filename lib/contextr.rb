module ContextR
end

# vendor code by rails and Cristian Neukirchen and _why
%w{active_support_subset dynamic}.each { |file|
      require File.dirname(__FILE__) + "/ext/#{file}" }

# modules that encapsulate certain simple aspects
%w{mutex_code unique_id}.each { |file|
      require File.dirname(__FILE__) + "/contextr/modules/#{file}" }

# the basic library code
%w{public_api class_methods layer 
   event_machine core_ext
   inner_class}.each { | file | 
      require File.dirname(__FILE__) + "/contextr/#{file}" }

unless Dynamic.variables.include?( :layers )
  Dynamic.variable( :layers => [] )
end
