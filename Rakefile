require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/rdoctask'
require 'spec/rake/spectask'

Rake::RDocTask.new do |rdoc|
  version = Bcdatabase::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bcdatabase #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec
