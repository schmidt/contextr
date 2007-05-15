require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require 'hoe'
include FileUtils
require File.join(File.dirname(__FILE__), 'lib', 'contextr', 'version')

AUTHOR = 'schmidt'  # can also be an array of Authors
EMAIL = "ruby@schmidtwisser.de"
DESCRIPTION = "The goal is to equip Ruby with an API to allow context-oriented programming."
GEM_NAME = 'contextr' # what ppl will type to install your gem
RUBYFORGE_PROJECT = 'contextr' # The unix name for your project
HOMEPATH = "http://#{RUBYFORGE_PROJECT}.rubyforge.org"
DOWNLOAD_PATH = "http://rubyforge.org/projects/#{RUBYFORGE_PROJECT}"

NAME = "contextr"
REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
VERS = ContextR::VERSION::STRING + (REV ? ".#{REV}" : "")
CLEAN.include ['**/.*.sw?', '*.gem', '.config', '**/.DS_Store']
RDOC_OPTS = ['--quiet', '--title', 'contextr documentation',
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README",
    "--inline-source"]

class Hoe
  def extra_deps 
    @extra_deps.reject { |x| Array(x).first == 'hoe' } 
  end 
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
hoe = Hoe.new(GEM_NAME, VERS) do |p|
  p.author = AUTHOR 
  p.description = DESCRIPTION
  p.email = EMAIL
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.test_globs = ["test/**/test_*.rb"]
  p.clean_globs = CLEAN  #An array of file patterns to delete on clean.
  
  # == Optional
  p.changes = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  #p.extra_deps = []     # An array of rubygem dependencies [name, version], e.g. [ ['active_support', '>= 1.3.1'] ]
  #p.spec_extras = {}    # A hash of extra values to set in the gemspec.
end


desc 'Generate website files'
task :website_generate do
  Dir['website/**/*.txt'].each do |txt|
    sh %{ ruby scripts/txt2html #{txt} > #{txt.gsub(/txt$/,'html')} }
  end
end

desc 'Upload website files to rubyforge'
task :website_upload do
  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
  host = "#{config["username"]}@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/"
  # remote_dir = "/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/#{GEM_NAME}"
  local_dir = 'website'
  sh %{rsync -av --exclude=".*/" #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload]

desc 'Release the website and new gem version'
task :deploy => [:check_version, :website, :release]

task :check_version do
  unless ENV['VERSION']
    puts 'Must pass a VERSION=x.y.z release version'
    exit
  end
  unless ENV['VERSION'] == VERS
    puts "Please update your version.rb to match the release version, currently #{VERS}"
    exit
  end
end

#desc 'Submit the docs HTML files to RubyForge'
#task :docs_publish => [ :docs ] do
#  config = YAML.load(File.read(File.expand_path("~/.rubyforge/user-config.yml")))
#  host = "#{config["username"]}@rubyforge.org"
#  remote_dir = "/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/api"
#  local_dir = 'doc'
#  sh %{rsync -av --delete-excluded --exclude=".*/" #{local_dir}/ #{host}:#{remote_dir}}
#end

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

desc "Run all benchmarks - currently none"
task :benchmark

