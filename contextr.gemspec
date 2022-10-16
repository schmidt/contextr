# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{contextr}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gregor Schmidt"]
  s.date = %q{2009-12-03}
  s.description = %q{The goal is to equip Ruby with an API to allow context-oriented programming.}
  s.email = %q{ruby@schmidtwisser.de}
  s.extra_rdoc_files = [
    "LICENSE.txt",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "GPL.txt",
     "History.txt",
     "LICENSE.txt",
     "MIT.txt",
     "README.rdoc",
     "RUBY.txt",
     "Rakefile",
     "TODO.taskpaper",
     "VERSION.yml",
     "autotest/discover.rb",
     "autotest/rspec_test.rb",
     "benchmark/contextr/bench.rb",
     "benchmark/contextr/results_for_different_hashes.txt",
     "contextr.gemspec",
     "examples/README",
     "examples/employer.rb",
     "examples/node.rb",
     "lib/contextr.rb",
     "lib/contextr/class_methods.rb",
     "lib/contextr/core_ext.rb",
     "lib/contextr/core_ext/module.rb",
     "lib/contextr/core_ext/object.rb",
     "lib/contextr/event_machine.rb",
     "lib/contextr/inner_class.rb",
     "lib/contextr/layer.rb",
     "lib/contextr/modules/mutex_code.rb",
     "lib/contextr/modules/unique_id.rb",
     "lib/contextr/public_api.rb",
     "lib/ext/active_support_subset.rb",
     "lib/ext/dynamic.rb",
     "setup.rb",
     "spec/contextr_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "test/class_side.mkd",
     "test/dynamic_scope.mkd",
     "test/dynamics.mkd",
     "test/hello_world.mkd",
     "test/introduction.mkd",
     "test/layer_state.mkd",
     "test/lib/example_test.rb",
     "test/lib/literate_maruku_test.rb",
     "test/meta_api.mkd",
     "test/method_missing.mkd",
     "test/ordering.mkd",
     "test/restrictions.mkd",
     "test/test_contextr.rb",
     "test/test_helper.rb",
     "test/test_plain.rb",
     "website/ContextR_euruko_2008.pdf",
     "website/index.html",
     "website/index.txt",
     "website/javascripts/rounded_corners_lite.inc.js",
     "website/stylesheets/screen.css",
     "website/template.rhtml"
  ]
  s.homepage = %q{http://github.com/schmidt/contextr}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Context-oriented programming API for Ruby}
  s.test_files = [
    "spec/contextr_spec.rb",
     "spec/spec_helper.rb",
     "test/lib/example_test.rb",
     "test/lib/literate_maruku_test.rb",
     "test/test_contextr.rb",
     "test/test_helper.rb",
     "test/test_plain.rb",
     "examples/employer.rb",
     "examples/node.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<markaby>, [">= 0"])
      s.add_development_dependency(%q<literate_maruku>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.4.0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<markaby>, [">= 0"])
      s.add_dependency(%q<literate_maruku>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 1.4.0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<markaby>, [">= 0"])
    s.add_dependency(%q<literate_maruku>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 1.4.0"])
  end
end
