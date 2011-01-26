require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/rdoctask'
require 'spec/rake/spectask'

Rake::RDocTask.new do |rdoc|
  version = Bcdatabase::VERSION

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "schema_qualified_tables #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

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

task :default => :spec
