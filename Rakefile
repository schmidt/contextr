require 'rake'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "contextr"
    gemspec.summary = "Context-oriented programming API for Ruby"
    gemspec.description = "The goal is to equip Ruby with an API to allow " +
                          "context-oriented programming."
    gemspec.email = "ruby@schmidtwisser.de"
    gemspec.homepage = "http://github.com/schmidt/contextr"
    gemspec.authors = ["Gregor Schmidt"]

    gemspec.add_development_dependency('rake')
    gemspec.add_development_dependency('markaby')
    gemspec.add_development_dependency('literate_maruku')
    gemspec.add_development_dependency('rspec')
    gemspec.add_development_dependency('jeweler', '>= 1.4.0')
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

desc 'Generate documentation for the literate_maruku gem.'
Rake::RDocTask.new(:doc) do |doc|
  doc.rdoc_dir = 'doc'
  doc.title = 'ContextR'
  doc.options << '--line-numbers' << '--inline-source'
  doc.rdoc_files.include('README.rdoc')
  doc.rdoc_files.include('lib/**/*.rb')
end

desc "Run the tests under test"
task :test do
  require 'rake/runtest'
  Rake.run_tests 'test/**/test_*.rb'
end

begin
  require 'spec/rake/spectask'
  desc "Run the specs under spec"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/*_spec.rb']
  end
rescue LoadError
  puts "RSpec not available. Install it with: sudo gem install rspec"
end

desc "Run specs and tests by default"
task :default => [:spec, :test]
