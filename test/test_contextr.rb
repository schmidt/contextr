# ContextR uses RSpec to test its implementation. For the relevant code
# have a look at the spec folder.
#
# Additionally ContextR has lots of descriptive manuals that are automatically
# converted to tests, to make sure, that all documentation is in sync with
# the implementation. You may find these documents in this directory. It is
# just, that they do not look like test, but they are. Believe me.
require File.dirname(__FILE__) + "/test_helper.rb"

%w(class_side dynamic_scope dynamics hello_world introduction
   layer_state meta_api ordering restrictions).each do |test|
  test_class("test_#{test}".camelcase.to_sym)
  LiterateMarukuTest.load(test)
end
