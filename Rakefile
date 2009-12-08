require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bcdatabase"
    gem.summary = %Q{Server-central database configuration for rails and other ruby apps}
    gem.description = %Q{bcdatabase is a tool for storing passwords and other database configuration information outside of your application source tree.}
    gem.email = "rhett@detailedbalance.net"
    gem.homepage = "http://github.com/rsutphin/bcdatabase"
    gem.authors = ["Rhett Sutphin"]
    gem.add_development_dependency 'rspec', ">= 1.2"
    gem.add_dependency 'highline', '>= 1.4'
    gem.add_dependency 'activesupport', '>= 2.0'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  # rcov can't tell that /Library/Ruby is a system path
  spec.rcov_opts = ['--exclude', "spec/*,/Library/Ruby/*"]
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "schema_qualified_tables #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Disable github release since I don't want to commit the gemspec
Rake::Task[:release].prerequisites.delete 'github:release'

task :build => [:gemspec]
