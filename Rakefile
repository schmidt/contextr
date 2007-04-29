# Most of this code was taken from the Rubinius Rakefile. 
# Thanks for the help.

ROOT = File.expand_path(File.dirname(__FILE__))

def load_files(files)
  files.each do |path|
    begin
      require(path)
    rescue Object => e
      STDERR.puts "Unable to load #{path}. #{e.message} (#{e.class})"
    end
  end
end
def require_files(files)
  files.each do |path|
    begin
      require(path)
    rescue Object => e
      STDERR.puts "Unable to load #{path}. #{e.message} (#{e.class})"
    end
  end
end

begin
    require 'spec/rake/spectask'
rescue LoadError
    raise <<-EOM
Unable to load spec/rake/spectask. RSpec is a requirement to build Rubinius.
Please install RSpec before building (http://rspec.rubyforge.org).
    EOM
end

# Task class extensions
paths = Dir[ File.join(File.dirname(__FILE__), 'rake/*') ]
require_files(paths)
#
# Other tasks 
paths = Dir[ File.join(File.dirname(__FILE__), 'tasks/*') ]
load_files(paths)

desc "Run all specs and tests"
task :default => [ :spec, :test ]

task :spec => 'spec:all'

# Generate all the spec tasks
namespace :spec do

  spec_targets = %w(contextr core_ext)

  spec_targets.each do | group |
    spec_files = Dir[ File.join( File.dirname(__FILE__), 
                      "spec/#{group}/*_spec.rb") ]

    GroupSpecTask.new( group )

    namespace group do
      spec_files.each do | file |
        SpecificGroupSpecTask.new( File.basename( file, '_spec.rb'), group )
      end
    end
  end
  
  desc "Run all specs."
  task :all => spec_targets.collect! { | group | 'spec:' << group }
end

desc "Run all tests - currently none"
task :test

desc "Run all benchmarks"
task :benchmark
